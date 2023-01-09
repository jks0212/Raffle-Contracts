// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// contract Raffle is IERC721Receiver, ReentrancyGuard{
//   using Counters for Counters.Counter;
// 	Counters.Counter private _itemIds;
// 	Counters.Counter private _itemsSold;
	
// 	address payable owner;
// 	uint256 public listingFee = 0.001 ether;

//   struct SimpleRaffleItem {
//     uint itemId;
//     uint256 tokenId;
//     address payable seller;
//     address payable owner;
//     uint256 price;
//   //   bool ended;
//     uint expiredAt;
//     uint ticketCap;
//   //   mapping(address => uint) gamblerTickets;
//   }

//   struct RaffleItem {
//     uint itemId;
//     uint256 tokenId;
//     address payable seller;
//     address payable owner;
//     uint256 price;
//     bool ended; // 티켓 다 팔리면 true 

//     uint expiredAt;
//     uint ticketCap;
//     mapping(address => uint) gamblerTickets;
//     address[] gamblerAddrs;
//   }

//   mapping(uint256 => RaffleItem) public vaultItems;

//   event NFTRaffleCreated (
//     uint indexed itemId,
//     uint256 indexed tokenId,
//     address seller,
//     address owner,
//     uint256 price,
//     bool ended,
//     uint expiredAt
//   );

//   function getListingFee() public view returns(uint256) {
//     return listingFee;
//   }

//   ERC721Enumerable nft;

//   // constructor(ERC721Enumerable _nft) {
//   //   owner = payable(msg.sender);
//   //   nft = _nft;
//   // }

//   function addRaffle(uint256 tokenId, uint256 price, uint expiredAt, uint ticketCap) public payable nonReentrant {
//     require(nft.ownerOf(tokenId) == msg.sender, "This NFT is not owned by this wallet.");
//     require(vaultItems[tokenId].tokenId == 0, "Already listed.");
//     require(price > 0, "Listing price must be higher than 0.");
//     require(msg.value == listingFee, "Not enough fee.");

//     // 래플 등록 때마다 itemId 번호 증가, 1번부터 시작
//     _itemIds.increment();
//     uint itemId = _itemIds.current();
//     // vaultItems[itemId] = RaffleItem(itemId, tokenId, payable(msg.sender), payable(address(this)), price, false, expiredAt, ticketCap);
//     RaffleItem storage raffleItem = vaultItems[itemId];
//     raffleItem.itemId = itemId;
//     raffleItem.tokenId = tokenId;
//     raffleItem.seller = payable(msg.sender);
//     raffleItem.owner = payable(address(this));
//     raffleItem.price = price;
//     raffleItem.ended = false;
//     raffleItem.expiredAt = expiredAt;
//     raffleItem.ticketCap = ticketCap;
    
//     // 컨트랙트에 해당 NFT 전송
//     nft.transferFrom(msg.sender, address(this), tokenId);
    
//     // Listing이 되면 event emit
//     emit NFTRaffleCreated(itemId, tokenId, msg.sender, address(this), price, false, expiredAt);
//   }

//   function buyNFT(uint256 itemId) public payable nonReentrant {
//     uint256 price = vaultItems[itemId].price;
//     uint256 tokenId = vaultItems[itemId].tokenId;

//     require(msg.value == price, "Exact amount of price is required.");
    
//     vaultItems[itemId].seller.transfer(msg.value);
//     payable(msg.sender).transfer(listingFee);
//     nft.transferFrom(address(this), msg.sender, tokenId);
//     vaultItems[itemId].ended = true;
//     _itemsSold.increment();

//     delete vaultItems[tokenId];
//     delete vaultItems[itemId];
//   }

//   function nftListings() public view returns (SimpleRaffleItem[] memory) {
//     uint itemCount = _itemIds.current();
//     uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
//     uint currentIndex = 0;

//     SimpleRaffleItem[] memory items = new SimpleRaffleItem[](unsoldItemCount);

//     for (uint i = 0; i < itemCount; i++) {
//       if (vaultItems[i+1].owner == address(this)) {
//         // uint currentId = i + 1;
//         // RaffleItem storage currentItem = vaultItems[currentId];
//         // items[currentIndex] = currentItem;
//         items[currentIndex] = SimpleRaffleItem(
//           vaultItems[i + 1].itemId, 
//           vaultItems[i + 1].tokenId, 
//           vaultItems[i + 1].seller, 
//           vaultItems[i + 1].owner, 
//           vaultItems[i + 1].price, 
//           vaultItems[i + 1].expiredAt, 
//           vaultItems[i + 1].ticketCap);
//         currentIndex += 1;
//       }
//     }
//     return items;
//   }

//   function onERC721Received(
//     address,
//     address from,
//     uint256,
//     bytes calldata
//   ) external pure override returns (bytes4) {
//     require(from == address(0x0), "Cannot send nfts to Vault directly");
//     return IERC721Receiver.onERC721Received.selector;
//   }

//   // 이더 전송 처리 부분 필요
//   function joinRaffle(uint256 tokenId, uint ticketNum) public {
//     uint ticketCap = vaultItems[tokenId].ticketCap;
//     uint currentTicketCap = 0;
//     for(uint i=0; i<vaultItems[tokenId].gamblerAddrs.length; i++) {
//       address addr = vaultItems[tokenId].gamblerAddrs[i];
//       currentTicketCap += vaultItems[tokenId].gamblerTickets[addr];
//     }

//     require(currentTicketCap + ticketNum <= ticketCap, "Gambler's tickets are too many to join");

//     // 최초 참가자라면 티켓 갯수가 0
//     if(vaultItems[tokenId].gamblerTickets[msg.sender] == 0) {
//       // msg.sender is Gambler?
//       vaultItems[tokenId].gamblerAddrs.push(msg.sender);
//     }
//     vaultItems[tokenId].gamblerTickets[msg.sender] += ticketNum;

//     // 티켓 캡이 다 차면 마감 처리
//     if(currentTicketCap + ticketNum == ticketCap) {
//       closeRaffle();
//     }
//   }

//   // 써드파티에서 이 함수를 주기적으로 호출
//   function checkExpiredRaffles() public {
//     require(owner == msg.sender, "Only owner can execute this.");
//     uint itemCount = _itemIds.current();

//     for (uint i = 1; i < itemCount - 1; i++) {
//       if(vaultItems[i].expiredAt <= block.timestamp) {
//         // 만료된 래플 처리
//         closeRaffle();
//       }
//     }

//   }

//   // case1. winner가 정해졌을 때 -> 우리가 직접 winner에게 전송
//   // case2. winner가 없을 때 -> 각각의 참여자들에게 claim할 수 있게
//   function closeRaffle() public {

//   }

// }

contract Raffle is IERC721Receiver, ReentrancyGuard{

  address public owner;
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
    owner = _owner;
    nftContract = _nftContract;
    nftTokenId = _nftTokenId;
    nftTokenType = _nftTokenType;
    expiredAt = _expiredAt;
    ticketCap = _ticketCap;
    ticketPrice = _ticketPrice;
    ticketPricePointer = _ticketPricePointer;

    // // 컨트랙트에 해당 NFT 전송
    // nft.transferFrom(msg.sender, address(this), tokenId);
  }

  function getRaffle() public view returns(
    address, 
    address, 
    uint256, 
    uint256, 
    uint256, 
    uint16, 
    uint32, 
    uint8
  ) {

    return(
      owner, 
      nftContract, 
      nftTokenId, 
      nftTokenType, 
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

  // event NFTRaffleCreated (
  //   uint indexed itemId,
  //   uint256 indexed tokenId,
  //   address seller,
  //   address owner,
  //   uint256 price,
  //   bool ended,
  //   uint expiredAt
  // );

  // function getListingFee() public view returns(uint256) {
  //   return listingFee;
  // }

  // constructor(ERC721Enumerable _nft) {
  //   owner = payable(msg.sender);
  //   nft = _nft;
  // }

  // function buyNFT(uint256 itemId) public payable nonReentrant {
  //   uint256 price = vaultItems[itemId].price;
  //   uint256 tokenId = vaultItems[itemId].tokenId;

  //   require(msg.value == price, "Exact amount of price is required.");
    
  //   vaultItems[itemId].seller.transfer(msg.value);
  //   payable(msg.sender).transfer(listingFee);
  //   nft.transferFrom(address(this), msg.sender, tokenId);
  //   vaultItems[itemId].ended = true;
  //   _itemsSold.increment();

  //   delete vaultItems[tokenId];
  //   delete vaultItems[itemId];
  // }

  // function nftListings() public view returns (SimpleRaffleItem[] memory) {
  //   uint itemCount = _itemIds.current();
  //   uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
  //   uint currentIndex = 0;

  //   SimpleRaffleItem[] memory items = new SimpleRaffleItem[](unsoldItemCount);

  //   for (uint i = 0; i < itemCount; i++) {
  //     if (vaultItems[i+1].owner == address(this)) {
  //       // uint currentId = i + 1;
  //       // RaffleItem storage currentItem = vaultItems[currentId];
  //       // items[currentIndex] = currentItem;
  //       items[currentIndex] = SimpleRaffleItem(
  //         vaultItems[i + 1].itemId, 
  //         vaultItems[i + 1].tokenId, 
  //         vaultItems[i + 1].seller, 
  //         vaultItems[i + 1].owner, 
  //         vaultItems[i + 1].price, 
  //         vaultItems[i + 1].expiredAt, 
  //         vaultItems[i + 1].ticketCap);
  //       currentIndex += 1;
  //     }
  //   }
  //   return items;
  // }

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
  function purchaseTickets(address purchaser, uint timestamp, uint16 tickets) public {
    uint currentTicketCap = 0;
    for(uint i=0; i<purchases.length; i++) {
      currentTicketCap += purchases[i].tickets;
    }

    require(currentTicketCap + tickets <= ticketCap, "Purchaser's tickets are too many to join");

    purchases.push(Purchase(purchaser, timestamp, tickets));

    // 티켓 캡이 다 차면 마감 처리
    if(currentTicketCap + tickets == ticketCap) {
      // closeRaffle();
    }
  }

}