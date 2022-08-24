//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTCollection is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string public baseURI;
    string public baseExtension = ".json";
    uint256 public mintfees = 0.5 ether;
    uint256 public cost = 0.5 ether;
    uint256 public maxSupply = 100;
    bool public paused = false;
    address private Owner;

    constructor(string memory _name, string memory _symbol, string memory _initBaseURI) 
    ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        Owner = msg.sender;    
        
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function mint(address _to, uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(!paused);
        require(_mintAmount > 0);
        require(supply + _mintAmount <= maxSupply);
 
        if (msg.sender != owner()) {
            revert("You cannot mint.");    
        }

        else {
            require(_mintAmount <= maxSupply, "Cannot Mint more than MaxSupply.");
            require(msg.value >= mintfees * _mintAmount,"Wrong Amount");
            for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(_to, supply + i);
            } 
        }
   
    }

    function walletOfOwner(address owner_)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(owner_);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner_, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory currentBaseURI = _baseURI();
        
        
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }


     function buyNFT(uint256 _tokenId) external payable {
        require(!paused);
        require(balanceOf(Owner) >= (maxSupply * 100/1000),"Exceed Your Mint Limit");
        require(msg.value <= cost,"Wrong Amount");
        address seller = ownerOf(_tokenId);
        _transfer(seller, msg.sender, _tokenId);
        payable(seller).transfer(msg.value);
    }
        
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }


    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

}