// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "contracts/Raffle.sol";

contract RaffleManager {

  address private owner;
  Raffle[] private raffles;
  Raffle[] private endedRaffles;

  struct SimpleNFT {
    address contractAddress;
    uint256 tokenId;
  }

  struct RaffleDetail {
    address owner;
    address raffleContract;
    address nftContract;
    uint256 nftTokenId;
    uint256 nftTokenType;
    uint256 expiredAt;
    uint16 ticketCap;
    uint16 soldTickets;
    uint32 ticketPrice;
    uint8 ticketPricePointer;
    uint32 index;
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
    uint32 ticketPrice,
    uint8 ticketPricePointer,
    address raffleAddress
  );

  function createRaffle(
    address raffleOwner,
    address nftContract,
    uint256 nftTokenId,
    uint256 nftTokenType,
    uint256 expiredAt,
    uint16 ticketCap,
    uint32 ticketPrice,
    uint8 ticketPricePointer
  ) public {
    // require(nft.ownerOf(tokenId) == msg.sender, "This NFT is not owned by this wallet.");
    // require(vaultItems[tokenId].tokenId == 0, "Already listed.");
    // require(price > 0, "Listing price must be higher than 0.");
    // require(msg.value == listingFee, "Not enough fee.");

    require(!doesRaffleAlreadyExist(nftContract, nftTokenId), "This NFT Raffle is already created.");
    // for(uint i=0; i<raffles.length; i++) {
    //   require(raffles[i].nftContract() != nftContract && raffles[i].nftTokenId() != nftTokenId, "This NFT Raffle is already created.");
    // }

    Raffle raffle = new Raffle(
      raffleOwner, 
      nftContract, 
      nftTokenId, 
      nftTokenType, 
      expiredAt, 
      ticketCap, 
      ticketPrice, 
      ticketPricePointer
    );
    raffles.push(raffle);

    emit NFTRaffleCreated(
      raffleOwner, 
      nftContract, 
      nftTokenId, 
      nftTokenType, 
      expiredAt, 
      ticketCap, 
      ticketPrice, 
      ticketPricePointer,
      address(raffle)
    );
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
      details[i] = RaffleDetail(
        raffles[i].owner(),
        address(raffles[i]),
        raffles[i].nftContract(),
        raffles[i].nftTokenId(),
        raffles[i].nftTokenType(),
        raffles[i].expiredAt(),
        raffles[i].ticketCap(),
        raffles[i].getSoldTicketsNum(),
        raffles[i].ticketPrice(),
        raffles[i].ticketPricePointer(),
        uint32(i)
      );
    }

    return details;
  }

  function abs(int256 x) private pure returns (int256) {
    return x >= 0 ? x : -x;
}

  function doesRaffleAlreadyExist(address nftContract, uint256 nftTokenId) private view returns(bool) {
    for(uint i=0; i<raffles.length; i++) {
      if(raffles[i].nftContract() == nftContract && raffles[i].nftTokenId() == nftTokenId) {
        return true;
      }
      return false;
    }
  }

  function getRaffleNFTsByOwner(address raffleOwner) public view returns(SimpleNFT[] memory) {
    uint size = 0;
    for(uint i=0; i < raffles.length; i++) {
      if(raffles[i].owner() == raffleOwner) {
        size += 1;
      }
    }

    SimpleNFT[] memory nfts = new SimpleNFT[](size);

    uint k=0;
    for(uint i=0; i < raffles.length; i++) {
      if(raffles[i].owner() == raffleOwner) {
        nfts[k++] = SimpleNFT(raffles[i].nftContract(), raffles[i].nftTokenId());
        // ownerRaffles[k++] = raffles[i];
      }
    }

    return nfts;
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
        details[k++] = RaffleDetail(
          raffles[i].owner(),
          address(raffles[i]),
          raffles[i].nftContract(),
          raffles[i].nftTokenId(),
          raffles[i].nftTokenType(),
          raffles[i].expiredAt(),
          raffles[i].ticketCap(),
          raffles[i].getSoldTicketsNum(),
          raffles[i].ticketPrice(),
          raffles[i].ticketPricePointer(),
          uint32(i)
        );
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
        closeRaffle();
      }
    }

  }

  // case1. winner가 정해졌을 때 -> 우리가 직접 winner에게 전송
  // case2. winner가 없을 때 -> 각각의 참여자들에게 claim할 수 있게
  function closeRaffle() public {

  }

  // mapping(uint256 => Raffle) raffleMap;

}