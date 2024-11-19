// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Web3Builder is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {

    uint256 private _nextTokenId;
    uint256 public maxSupply = 2000;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;

    mapping(address => bool) public allowList;

    constructor(address initialOwner)
    ERC721("Web3Builder", "WE3")
    Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmY5rPqGTN1rZxMQg2ApiSZc7JiBNs1ryDzXPZpQhC1ibm/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function editMintWindows(bool _publicMintOpen, bool _allowListMintOpen) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;

    }

    function allowListMint() public payable {
        require(allowListMintOpen == true, "Allow list mint is closed");
        require(allowList[msg.sender] == true, "You are not listed on the allow list");
        require(msg.value == 0.001 ether, "Not enough Funds");
        internalMint();
    }

    function publicMint() public payable {
        require(publicMintOpen == true, "Public mint is closed");
        require(msg.value == 0.01 ether, "Not enough funds");
        internalMint();
    }

    function internalMint() internal {
        require(totalSupply() < maxSupply, "We have sold out!");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function withdraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
    }

    function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++) {
            allowList[addresses[i]] = true;
        }
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
    internal
    override(ERC721, ERC721Enumerable, ERC721Pausable)
    returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
    internal
    override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}