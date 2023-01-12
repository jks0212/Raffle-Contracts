// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "contracts/Raffle.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract RaffleManager {

  address private owner;
  Raffle[] private raffles;
  Raffle[] private endedRaffles;

  struct SimpleRaffle {
    address contractAddress;
    uint256 tokenId;
    uint8 state;
  }

  struct RaffleDetail {
    address owner;
    address raffleContract;
    address nftContract;
    uint256 nftTokenId;
    uint256 nftTokenType;
    string nftName;
    string nftSymbol;
    string nftTokenURI;
    uint256 expiredAt;
    uint16 ticketCap;
    uint16 soldTickets;
    uint256 ticketPrice;
    uint32 index;
    uint8 state;
  }

  constructor() {
    owner = msg.sender;
  }

  event NFTRaffleCreated (
    address raffleOwner,
    address nftContract,
    uint256 nftTokenId,
    uint256 nftTokenType,
    uint256 expiredAt, 
    uint16 ticketCap, 
    uint256 ticketPrice,
    address raffleAddress
  );

  function createRaffle(
    // address raffleOwner,
    address nftContract,
    uint256 nftTokenId,
    uint256 nftTokenType,
    uint256 expiredAt,
    uint16 ticketCap,
    uint256 ticketPrice
  ) public {
    // require(nft.ownerOf(tokenId) == msg.sender, "This NFT is not owned by this wallet.");
    // require(vaultItems[tokenId].tokenId == 0, "Already listed.");
    // require(price > 0, "Listing price must be higher than 0.");
    // require(msg.value == listingFee, "Not enough fee.");
    require(nftTokenType == 721, "Currently only ERC721 token is supported.");
    require(!doesRaffleAlreadyExist(nftContract, nftTokenId), "This NFT Raffle is already created.");


    Raffle raffle = new Raffle(
      // raffleOwner, 
      msg.sender,
      nftContract, 
      nftTokenId, 
      nftTokenType, 
      expiredAt, 
      ticketCap, 
      ticketPrice
    );
    raffles.push(raffle);

    transferERC721(nftContract, msg.sender, address(raffle), nftTokenId);

    emit NFTRaffleCreated(
      // raffleOwner, 
      msg.sender,
      nftContract, 
      nftTokenId, 
      nftTokenType, 
      expiredAt, 
      ticketCap, 
      ticketPrice,
      address(raffle)
    );
  }

  function transferERC721(address nft, address from, address to, uint256 tokenId) public payable {
    IERC721 erc721 = IERC721(nft);
    require(erc721.ownerOf(tokenId) == from, "You should be the owner of this NFT.");
    erc721.transferFrom(from, to, tokenId);
  }

  function getRaffles() public view returns(Raffle[] memory) {
    return raffles;
  }

  function getRafflesByIndex(uint256 index, uint256 itemNums) public view returns(RaffleDetail[] memory) {
    require(itemNums <= 100, "Too many items to request.");
    if(index >= raffles.length) {
      return new RaffleDetail[](0);
    }

    int256 diff = int256(raffles.length) - int256(itemNums + index);
    uint256 max = diff < 0 ? raffles.length : itemNums + index;
    uint256 size = diff < 0 ? max - index : itemNums;
    
    RaffleDetail[] memory details = new RaffleDetail[](size);
    for(uint i=index; i<max; i++) {
      uint256 tokenType = raffles[i].nftTokenType();
      if(tokenType == 721){
        string memory nftName;
        string memory nftSymbol;
        string memory nftTokenURI;
        (nftName, nftSymbol, nftTokenURI) = raffles[i].getERC721Metadata();

        details[i] = RaffleDetail(
          raffles[i].owner(),
          address(raffles[i]),
          raffles[i].nftContract(),
          raffles[i].nftTokenId(),
          raffles[i].nftTokenType(),
          nftName,
          nftSymbol,
          nftTokenURI,
          raffles[i].expiredAt(),
          raffles[i].ticketCap(),
          raffles[i].getSoldTicketsNum(),
          raffles[i].ticketPrice(),
          uint32(i),
          raffles[i].getStateNum()
        );
      } else if(tokenType == 1155) {

      }
    }

    return details;
  }

  function doesRaffleAlreadyExist(address nftContract, uint256 nftTokenId) private view returns(bool) {
    for(uint i=0; i<raffles.length; i++) {
      if(raffles[i].nftContract() == nftContract 
      && raffles[i].nftTokenId() == nftTokenId 
      && raffles[i].isOngoing()) {
        return true;
      }
      return false;
    }
  }

  function getRaffleNFTsByOwner(address raffleOwner) public view returns(SimpleRaffle[] memory) {
    uint size = 0;
    for(uint i=0; i < raffles.length; i++) {
      if(raffles[i].owner() == raffleOwner) {
        size += 1;
      }
    }

    SimpleRaffle[] memory simpleRaffles = new SimpleRaffle[](size);

    uint k=0;
    for(uint i=0; i < raffles.length; i++) {
      if(raffles[i].owner() == raffleOwner) {
        simpleRaffles[k++] = SimpleRaffle(
          raffles[i].nftContract(), 
          raffles[i].nftTokenId(),
          raffles[i].getStateNum()
        );
      }
    }

    return simpleRaffles;
  }

  function getRaffleDetailsByOwner(address raffleOwner) public view returns(RaffleDetail[] memory) {
    uint size = 0;
    for(uint i=0; i < raffles.length; i++) {
      if(raffles[i].owner() == raffleOwner) {
        size += 1;
      }
    }

    RaffleDetail[] memory details = new RaffleDetail[](size);

    uint k=0;
    for(uint i=0; i < raffles.length; i++) {
      if(raffles[i].owner() == raffleOwner) {
        uint256 tokenType = raffles[i].nftTokenType();
        if(tokenType == 721){
          string memory nftName;
          string memory nftSymbol;
          string memory nftTokenURI;
          (nftName, nftSymbol, nftTokenURI) = raffles[i].getERC721Metadata();

          details[k++] = RaffleDetail(
            raffles[i].owner(),
            address(raffles[i]),
            raffles[i].nftContract(),
            raffles[i].nftTokenId(),
            raffles[i].nftTokenType(),
            nftName,
            nftSymbol,
            nftTokenURI,
            raffles[i].expiredAt(),
            raffles[i].ticketCap(),
            raffles[i].getSoldTicketsNum(),
            raffles[i].ticketPrice(),
            uint32(i),
            raffles[i].getStateNum()
          );
        } else if(tokenType == 1155) {

        }
      }
    }

    return details;
  }

  function deleteRaffle() public {

  }

  function checkExpiredRaffles() public {
    require(owner == msg.sender, "Only owner can execute this.");

    for (uint i = 0; i < raffles.length; i++) {
      if(raffles[i].expiredAt() <= block.timestamp) {
        // 만료된 래플 처리
        // closeRaffle();
      }
    }

  }

}