// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "contracts/Raffle.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract RaffleManager {

  address private owner;
  Raffle[] private raffles;

  constructor() {
    owner = msg.sender;
  }

  event NFTRaffleCreated (
    uint256 expiredAt, 
    uint16 ticketCap, 
    uint32 ticketPrice,
    uint8 ticketPricePointer,
    address raffleAddress
  );

  function createRaffle(
    // ERC721Enumerable nft, 
    // uint256 tokenId,
    uint256 expiredAt, 
    uint16 ticketCap, 
    uint32 ticketPrice,
    uint8 ticketPricePointer
  ) public {
    // require(nft.ownerOf(tokenId) == msg.sender, "This NFT is not owned by this wallet.");
    // require(vaultItems[tokenId].tokenId == 0, "Already listed.");
    // require(price > 0, "Listing price must be higher than 0.");
    // require(msg.value == listingFee, "Not enough fee.");

    // Raffle raffle = new Raffle(nft, tokenId, expiredAt, ticketCap, ticketPrice);
    Raffle raffle = new Raffle(expiredAt, ticketCap, ticketPrice, ticketPricePointer);
    raffles.push(raffle);

    emit NFTRaffleCreated(expiredAt, ticketCap, ticketPrice, ticketPricePointer, address(raffle));
  }

  function getRaffles() public view returns(Raffle[] memory) {
    return raffles;
  }

  function deleteRaffle() public {

  }

  function checkExpiredRaffles() public {
    require(owner == msg.sender, "Only owner can execute this.");

    for (uint i = 0; i < raffles.length; i++) {
      if(raffles[i].getExpiredAt() <= block.timestamp) {
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