//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error NftMarketplace_priceMustBeAboveZero();
error NftMarketplace_NftNotApproveForMarketplace();
error NftMarketplace_NftAlreadyExists(address nftAddress, uint256 tokenId);
error NftMarketplace_NotOwner();
error NftMarketplace_NftNotListed(address nftAddress, uint256 tokenId);
error NotEnoghEth(address nftAddress, uint256 tokenId, uint256 price);
error NftMarketplace_DontHaveProceed();
error NftMarketplace_TransactionFailed();

contract NftMarketplace is ReentrancyGuard {

    /////////////////////
    ////  Events    /////
    /////////////////////
    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemBought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemCanceled(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );


    event ItemUpdates (
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );




    struct Listing {
        uint256 price;
        address sellerAddress;
    }




    //nft address -> tokenId -> Listings
    mapping(address => mapping(uint256 => Listing)) private s_listings;
    mapping(address => uint256) private s_proceeds;




    //////////////////////
    ////  Modifier    ////
    //////////////////////
    modifier AlreadyListed(
        address nftAddress,
        uint256 tokenId,
        address sender
    ) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price > 0) {
            revert NftMarketplace_NftAlreadyExists(nftAddress, tokenId);
        }
        _;
    }

    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address sender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (owner != sender) {
            revert NftMarketplace_NotOwner();
        }
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price <= 0) {
            revert NftMarketplace_NftNotListed(nftAddress, tokenId);
        }
        _;
    }

    //////////////////////
    ////Main Functions///
    //////////////////////

    /*
    /// @notice where ypu can list nft item on the market place
    /// @param nftAddress: the nft address to be listed
    /// @param tokenId: the nft token id
    /// @param price: the nft price
    /// @dev we can make this an escrow function but we technically want the nft 
       owner to be able to hold the nft when listed
    */

    function ListNftsItems(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        AlreadyListed(nftAddress, tokenId, msg.sender)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        if (price <= 0) {
            revert NftMarketplace_priceMustBeAboveZero();
        }

        ///sending nft to the contract
        // the owner can still hold their nft,and still give the market approval to sell the nft for them.
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NftMarketplace_NftNotApproveForMarketplace();
        }

        s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    function BuyItem(
        address nftAddress,
        uint256 tokenId
    ) external payable isListed(nftAddress, tokenId) nonReentrant {
        //write a modifier to check if the listing is availabe✅
        //the amount should not be lesser than the price✅
        //decalre a varaible on the s_listing mapping to access the Listins price ✅
        //should update the seller proceed ✅
        //should tranfer the nft from the seller to the buyer ✅
        //should delete the item fom the market place ✅
        //should emit an event✅
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        if (msg.value < listedItem.price) {
            revert NotEnoghEth(nftAddress, tokenId, listedItem.price);
        }

        s_proceeds[listedItem.sellerAddress] = s_proceeds[listedItem.sellerAddress] + msg.value;
        delete (s_listings[nftAddress][tokenId]);
        IERC721(nftAddress).safeTransferFrom(
            listedItem.sellerAddress,
            msg.sender,
            tokenId
        );
        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
    }

    function CancelItem(
        address nftAddress,
        uint256 tokenId
    )
        external
        isListed(nftAddress, tokenId)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        delete (s_listings[nftAddress][tokenId]);
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }

    function UpadteItem(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    )
        external
        isListed(nftAddress, tokenId)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        s_listings[nftAddress][tokenId].price = newPrice;
        emit ItemUpdates(msg.sender, nftAddress, tokenId, newPrice);
    }




    function WithdrawProceed () external {
        uint256 proceed = s_proceeds[msg.sender];
        if(proceed <= 0){
            revert NftMarketplace_DontHaveProceed();
        }

        s_proceeds[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: proceed}("");
        if(!success){
            revert NftMarketplace_TransactionFailed();
        }
    }


    function getListing(address nftAddress, uint256 tokenId) public view returns(Listing memory){
        return s_listings[nftAddress][tokenId];
    }

    function getProceeds (address sender) public view returns(uint256){
        return s_proceeds[sender];
    }
}

//  `ListItem`: to list nft on the market place✅
//  `BuyItem`: to buy nft ✅
//  `CancelItem`: to cancel a listing ✅
//  `UpadteItem`: update the price ✅
//  `WithdrawProceed`: to withdra payment
