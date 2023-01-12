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
    Soldout,
    Timeout,
    Cancelled,
    Completed
  }
  State private state;

  address payable public owner;
  address public nftContract;
  uint256 public nftTokenId;
  uint256 public nftTokenType;
  uint256 public expiredAt;
  uint16 public ticketCap;
  uint32 public ticketPrice;
  uint8 public ticketPricePointer;

  // address payable private seller;
  // address payable private owner;
  // uint256 price;
//   bool ended;

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
    uint32 _ticketPrice,
    uint8 _ticketPricePointer
  ) {
    owner = payable(_owner);
    nftContract = _nftContract;
    nftTokenId = _nftTokenId;
    nftTokenType = _nftTokenType;
    expiredAt = _expiredAt;
    ticketCap = _ticketCap;
    ticketPrice = _ticketPrice;
    ticketPricePointer = _ticketPricePointer;

    state = State.Ongoing;

    transferERC721(owner, address(this), nftTokenId);
    // IERC721 erc721 = IERC721(nftContract);
    // erc721.transferFrom(owner, address(this), nftTokenId);
  }

  function transferERC721(address from, address to, uint256 tokenId) public payable {
    IERC721 erc721 = IERC721(nftContract);
    erc721.transferFrom(from, to, tokenId);
    erc721.approve(to, tokenId); 
  }

  function cancelRaffle(address _owner) public {
    require(owner == _owner, "Only owner is able to cancel raffle.");

    state = State.Cancelled;

    transferERC721(address(this), owner, nftTokenId);

    // TODO 토큰 구매자들에게 다 돌려주기
  }

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
    uint32, 
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
      ticketPricePointer
    );
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

  // 이더 전송 처리 부분 필요
  function purchaseTickets(uint16 tickets, uint256 cost) public {
    require(state == State.Ongoing, "Raffle state is not on sail");

    uint currentTicketCap = 0;
    for(uint i=0; i<purchases.length; i++) {
      currentTicketCap += purchases[i].tickets;
    }

    require(currentTicketCap + tickets <= ticketCap, "Purchaser's tickets are too many to join");

    // purchases.push(Purchase(purchaser, timestamp, tickets));
    purchases.push(Purchase(msg.sender, block.timestamp, tickets));

    // 티켓 캡이 다 차면 마감 처리
    if(currentTicketCap + tickets == ticketCap) {
      state = State.Soldout;
      // closeRaffle();
    }
  }

}