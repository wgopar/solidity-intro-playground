// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import 'base64-sol/base64.sol';
import "hardhat/console.sol";


contract MyTokenV2 is ERC721URIStorage, Pausable, AccessControl, Ownable  {

    uint256 public mintCounter = 0;
    uint256 public mintLimit = 256;
    uint256 private size = 1000;
    mapping(address => uint) public minterToTokenId;
    mapping(uint256 => uint256) internal tokenIdToSeed;
    event Mint(uint256 tokenId);

    constructor(address adminAddress, string memory name, string memory symbol) ERC721(name, symbol){
        console.log("name", name);
        console.log("symbol", symbol);
        console.log("msg.sender", msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, adminAddress);
    }

    function mint(address _reciever) public whenNotPaused {
        require(balanceOf(msg.sender) < 5, "MINT_SESSION_EXCEEDED");
        require(mintCounter <= mintLimit, "MINT_LIMIT_REACHED");
        _mint(_reciever);
        _generateHash();
        console.log("This is the tokens random seed", tokenIdToSeed[mintCounter]);
        _setTokenURI(mintCounter, _formatTokenURI(fetchSVG(mintCounter), mintCounter));
    }

    function _mint(address _receiver) internal {
        mintCounter = mintCounter + 1;
        _safeMint(_receiver, mintCounter);
        emit Mint(mintCounter);
    }

    function _generateHash() internal {
      tokenIdToSeed[mintCounter] = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
    }

    function fetchSVG(uint256 tokenId) public view returns (string memory) {
      console.log("Fetch SVG called....");
      uint256[] memory traits = _getTokenTraits(tokenId);
      console.log("These are the token traits\n");

      // extract background color
      string memory bgColor;
      if (traits[0] < 2){
        bgColor = '#042069';
      }
      else if (traits[0] < 5){
        bgColor = '#56783c';
      }
      else if (traits[0] < 10){
        bgColor = '#00ff7f';
      }
      else if (traits[0] < 35){
        bgColor = '#a0db8e';
      }
      else if (traits[0] < 45){
        bgColor = '#798d87';
      }
      else {
        bgColor = '#8f0707';
      }
      console.log('Trait 0: ', uint2str(traits[0]));
      console.log(bgColor);

      // extract border traits
      string memory accumulator = string(abi.encodePacked("<svg viewBox='0 0 ", uint2str(size), " ", uint2str(size), "' height=\"100%\" width=\"100%\" xmlns=\"http://www.w3.org/2000/svg\" style=\"background: ", bgColor , "\">\n"));
      console.log('Trait 1: ' , uint2str(traits[1]));
      if (traits[1] > 75){
        accumulator = string(abi.encodePacked(accumulator,
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="10 10 480 480">\n',
          '<rect x="25" y="25" width="450" height="450" rx="0.25" style="stroke:red; stroke-width:2; fill-opacity:0; stroke-opacity:1;"/>\n',
          '</svg>\n'));
        console.log('Border!');
      }

      string memory path = _generatePath(traits);
      accumulator = string(abi.encodePacked(accumulator, path));

      accumulator = string(abi.encodePacked(accumulator, "</svg>"));
      string memory imageURI = string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(bytes(accumulator))));

      console.log('This is the fetched SVG log', imageURI);
      return imageURI;
    }

    function _generatePath(uint256[] memory traits) internal view returns(string memory){

      string memory origin = string(abi.encodePacked('d="M ', uint2str(traits[2]  * 10), ' ', uint2str(traits[3] * 10)));
      string memory quadratic_accumulator;
      for(uint i=0; i < 5; i++){
        quadratic_accumulator = string(abi.encodePacked(quadratic_accumulator, string(abi.encodePacked(' S ', uint2str(traits[i + 4] * 10), ',', uint2str(traits[i + 5] * 10),  ',', uint2str(traits[i + 6] * 10 ),  ',', uint2str(traits[i + 7] * 10), "'"))));
      }

      string memory pathDefinition = string(abi.encodePacked('<path id="pathDefinition" fill="yellow" stroke="black" ', origin, quadratic_accumulator, '"/>\n'));
      string memory path = "<text>\n"
                           '<textPath href="#pathDefinition">\n'
                            "**$***$*$**$*$*$$**$$$*$*$$*$*$*$$$$*$*$$*$*$**$*$*$**$$$$$$*$*$*$$$\n"
                           "</textPath>\n"
                           "</text>\n";

      return string(abi.encodePacked(pathDefinition, path));
    }

    function _getTokenTraits(uint256 tokenId) internal view returns(uint256[] memory){

      console.log('GETTING TOKEN TRIATS');
      uint256 randomHash = tokenIdToSeed[tokenId];
      uint256[] memory stats = new uint256[](23); // generate 23 random numbers ()
      for(uint256 i; i < 23; i++){
        stats[i] = randomHash % 100; // between 0 - 100 (probability)
        console.log(stats[i]);
        randomHash >>= 8;
      }
     return stats;
    }

    function _formatTokenURI(string memory imageURI, uint256 mintNumber) internal view returns (string memory) {

      return string(
              abi.encodePacked(
                  "data:application/json;base64,",
                  Base64.encode(
                      bytes(
                          abi.encodePacked(
                              '{"name": "Genesis #', uint2str(mintNumber) ,'",',
                              '"description": "Experimental project injected into the world.",',
                              '"attributes":"[', "xx" ,']",',
                              '"image":"', imageURI ,'"}'
                          )
                      )
                  )
              )
          );
    }

    function st2num(string memory numString) internal pure returns(uint) {
        uint  val=0;
        bytes   memory stringBytes = bytes(numString);
        for (uint  i =  0; i<stringBytes.length; i++) {
            uint exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
           uint jval = uval - uint(0x30);

           val +=  (uint(jval) * (10**(exp-1)));
        }
      return val;
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function setMintLimit(uint32 _mintLimit) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "NOT_ADMIN");
        mintLimit = _mintLimit;
    }

    function pause() public onlyOwner {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "NOT_ADMIN");
        _pause();
    }

    function unpause() public onlyOwner{
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "NOT_ADMIN");
        _unpause();
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
      return super.supportsInterface(interfaceId);
    }

}
