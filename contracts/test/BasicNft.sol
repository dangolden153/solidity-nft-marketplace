//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

pragma solidity ^0.8.7;

contract BasicNft is ERC721 {
    event GameItem(uint256 indexed s_tokenCounter);

    uint256 private s_counter;
    string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    constructor() ERC721("GameItem", "ITM") {
        s_counter = 0;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_counter);
        s_counter = s_counter + 1;
        emit GameItem(s_counter);
    }

    function tokenURI(
        uint256 //  tokenId
    ) public view virtual override returns (string memory) {
        return TOKEN_URI;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_counter;
    }
}
