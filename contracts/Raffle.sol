// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Raffle is IERC721Receiver, ReentrancyGuard{

  enum State {
    Ongoing,
    Timeout,
    Cancelled,
    Completed
  }

  // 1 ETH
  uint256 private listingFee = 1000000000000000000;

  State private state;

  address payable public owner;
  address public nftContract;
  uint256 public nftTokenId;
  uint256 public nftTokenType;
  uint256 public expiredAt;
  uint16 public ticketCap;
  uint256 public ticketPrice;

  uint256 private createdAt;

  address private winner;

  bool private didWinnerGetNft = false;
  bool private didOwnerGetBalance = false;

  struct Purchase {
    address purchaser;
    uint timestamp;
    uint16 tickets;
  }

  Purchase[] private purchases;

// payable nonReentrant
  constructor (
    address _owner,
    address _nftContract,
    uint256 _nftTokenId,
    uint256 _nftTokenType,
    uint256 _expiredAt,
    uint16 _ticketCap,
    uint256 _ticketPrice
  ) {
    owner = payable(_owner);
    nftContract = _nftContract;
    nftTokenId = _nftTokenId;
    nftTokenType = _nftTokenType;
    expiredAt = _expiredAt;
    ticketCap = _ticketCap;
    ticketPrice = _ticketPrice;
    createdAt = block.timestamp;
    state = State.Ongoing;
  }

  function transferERC721(address to) private {
    // IERC721 erc721 = IERC721(nftContract);

    // require(erc721.ownerOf(tokenId) == from, "You should be the owner of this NFT.");

    // if(!erc721.isApprovedForAll(owner, address(this))) {
    //   erc721.setApprovalForAll(address(this), true);
    // }
    IERC721(nftContract).transferFrom(address(this), to, nftTokenId);
  }

  // function cancelRaffle(address _owner) public {
  //   require(owner == _owner, "Only owner is able to cancel raffle.");
  //   require(state == State.Ongoing, "This raffle is done.");

  //   state = State.Cancelled;

  //   transferERC721(address(this), owner, nftTokenId);

  //   // TODO 토큰 구매자들에게 다 돌려주기
  // }

  function getRaffle() public view returns(
    address, 
    address, 
    uint256, 
    uint256, 
    string memory,
    string memory,
    string memory,
    uint256, 
    uint16, 
    uint256, 
    uint8
  ) {

    string memory nftName;
    string memory nftSymbol;
    string memory nftTokenURI;
    (nftName, nftSymbol, nftTokenURI) = getERC721Metadata();

    return(
      owner,
      nftContract, 
      nftTokenId, 
      nftTokenType, 
      nftName,
      nftSymbol,
      nftTokenURI,
      expiredAt, 
      ticketCap, 
      ticketPrice, 
      getStateNum()
    );
  }

  function getWinnerInfo() public view returns(address, bool) {
    return (winner ,didWinnerGetNft);
  }

  function getOwnerInfo() public view returns(address, bool) {
    return (owner, didOwnerGetBalance);
  }

  function getStateNum() public view returns(uint8) {
    uint8 _state;
    if(state == State.Ongoing) {
      _state = 1;
    } else if(state == State.Timeout) {
      _state = 2;
    } else if(state == State.Cancelled) {
      _state = 3;
    } else if(state == State.Completed) {
      _state = 4;
    }
    return _state;
  }

  function isOngoing() public view returns(bool) {
    
  }

  function getPurchases() public view returns(Purchase[] memory) {
    return purchases;
  }

  function getSoldTicketsNum() external view returns(uint16) {
    uint16 total = 0;
    for(uint i=0; i<purchases.length; i++) {
      total += purchases[i].tickets;
    }
    return total;
  }

  function getERC721Metadata() public view returns(string memory, string memory, string memory) {
      IERC721Metadata erc721Metadata = IERC721Metadata(nftContract);
      string memory name = erc721Metadata.name();
      string memory symbol = erc721Metadata.symbol();
      string memory tokenURI = erc721Metadata.tokenURI(nftTokenId);

      return (name, symbol, tokenURI);
  }

  function getERC1155Metadata(address contractAddress, uint256 tokenId) public view returns(string memory) {
      IERC1155MetadataURI erc1155MetadataURI = IERC1155MetadataURI(contractAddress);
      string memory uri = erc1155MetadataURI.uri(tokenId);
      return uri;
  }

  function onERC721Received(
    address,
    address from,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {
    require(from == address(0x0), "Cannot send nfts to Vault directly");
    return IERC721Receiver.onERC721Received.selector;
  }

  function purchaseTickets(uint16 tickets) public payable {
    require(ticketPrice * uint256(tickets) == msg.value, "Sent cost doesn't fit.");
    require(state == State.Ongoing, "This raffle is done.");

    uint currentTicketCap = 0;
    for(uint i=0; i<purchases.length; i++) {
      currentTicketCap += purchases[i].tickets;
    }

    require(currentTicketCap + tickets <= ticketCap, "Purchaser's tickets are too many to join");

    purchases.push(Purchase(msg.sender, block.timestamp, tickets));

    // 티켓 캡이 다 차면 마감 처리
    if(currentTicketCap + tickets == ticketCap) {
      winner = chooseWinner();
      state = State.Completed;
    }
  }

  function chooseWinner() private view returns(address) {
    uint256 ranNum = block.timestamp % ticketCap;

    uint256 winPoint = 0;
    address _winner;
    for(uint i=0; i<purchases.length; i++) {
      for(uint k=0; k<purchases[i].tickets; k++) {
        if(winPoint == ranNum) {
          _winner = purchases[i].purchaser;
          break;
        }
        winPoint += 1;
      }
    }

    return _winner;
  }

  function checkTimeout() public {
    if(expiredAt < block.timestamp) {
      state = State.Timeout;
    }
  }

  function giveNftToWinner() public {
    require(state == State.Completed, "Winner exists when raffle has been completed.");
    require(msg.sender == winner, "Only winner can take NFT.");

    transferERC721(winner);
    didWinnerGetNft = true;
  }

  function giveAllBalanceToOwner() public payable {
    require(state == State.Completed, "Raffle is not completed.");
    require(msg.sender == owner, "Not owner.");

    owner.transfer(address(this).balance);
    didOwnerGetBalance = true;
  }

}