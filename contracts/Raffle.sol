// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Raffle is IERC721Receiver, ReentrancyGuard{
	using Counters for Counters.Counter;
	Counters.Counter private _itemIds;
	Counters.Counter private _itemsSold;
	
	address payable owner;
	uint256 public listingFee = 0.001 ether;


  struct raffleList {
      uint itemId;
      uint256 tokenId;
      address payable seller;
      address payable owner;
      uint256 price;
      bool ended;
  }

  mapping(uint256 => raffleList) public vaultItems;

  event NFTRaffleCreated (
      uint indexed itemId,
      uint256 indexed tokenId,
      address seller,
      address owner,
      uint256 price,
      bool ended
  );

  function getListingFee() public view returns(uint256) {
      return listingFee;
  }

  ERC721Enumerable nft;

  constructor(ERC721Enumerable _nft) {
      owner = payable(msg.sender);
      nft = _nft;
  }

  function listRaffle(uint256 tokenId, uint256 price) public payable nonReentrant {
    require(nft.ownerOf(tokenId) == msg.sender, "This NFT is not owned by this wallet.");
    require(vaultItems[tokenId].tokenId == 0, "Already listed.");
    require(price > 0, "Listing price must be higher than 0.");
    require(msg.value == listingFee, "Not enough fee.");

    // 래플 등록 때마다 itemId 번호 증가, 1번부터 시작
    _itemIds.increment();
    uint itemId = _itemIds.current();
    vaultItems[itemId] = raffleList(itemId, tokenId, payable(msg.sender), payable(address(this)), price, false);
    
    // 컨트랙트에 해당 NFT 전송
    nft.transferFrom(msg.sender, address(this), tokenId);
    
    // Listing이 되면 event emit
    emit NFTRaffleCreated(itemId, tokenId, msg.sender, address(this), price, false);
  }

  function buyNFT(uint256 itemId) public payable nonReentrant {
      uint256 price = vaultItems[itemId].price;
      uint256 tokenId = vaultItems[itemId].tokenId;

      require(msg.value == price, "Exact amount of price is required.");
      
      vaultItems[itemId].seller.transfer(msg.value);
      payable(msg.sender).transfer(listingFee);
      nft.transferFrom(address(this), msg.sender, tokenId);
      vaultItems[itemId].ended = true;
      _itemsSold.increment();

      delete vaultItems[tokenId];
      delete vaultItems[itemId];
  }

  function nftListings() public view returns (raffleList[] memory) {
      uint itemCount = _itemIds.current();
      uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
      uint currentIndex = 0;

      raffleList[] memory items = new raffleList[](unsoldItemCount);

      for (uint i = 0; i < itemCount; i++) {
          if (vaultItems[i+1].owner == address(this)) {
              uint currentId = i + 1;
              raffleList storage currentItem = vaultItems[currentId];
              items[currentIndex] = currentItem;
              currentIndex += 1;
          }
      }
      return items;
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

}
