// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title NarutoRole
 * @author xiongren
 * @notice 创建角色合约 可直接set tokenURI用于更换角色 可直接mint
 */
contract NarutoRole is ERC721, Ownable {
    error NarutoRole_ERC721Metadata__URI_QueryFor_NonExistentToken();

    event NFTMinted(
        address from,
        address to,
        uint256 projectId,
        uint256 tokenId
    );

    enum Role {
        Sasuke_Uchiha,
        Naruto_Uzumaki,
        Itachi_Uchiha
    }

    string private s_Sasuke_Uchiha_Uri;
    string private s_Naruto_Uzumaki_Uri;
    string private s_Itachi_Uchiha_Uri;
    uint256 private s_tokenCounter;
    string private s_value;
    uint256 private s_projectId;

    mapping(uint256 => Role) private s_tokenIdToRole;

    constructor(
        string memory Sasuke_Uchiha_Uri,
        string memory Naruto_Uzumaki_Uri,
        string memory Itachi_Uchiha_Uri,
        string memory value,
        uint256 projectId
    ) ERC721("Naruto", "Naruto") Ownable(msg.sender) {
        s_Sasuke_Uchiha_Uri = Sasuke_Uchiha_Uri;
        s_Naruto_Uzumaki_Uri = Naruto_Uzumaki_Uri;
        s_Itachi_Uchiha_Uri = Itachi_Uchiha_Uri;
        s_value = value;
        s_projectId = projectId;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert NarutoRole_ERC721Metadata__URI_QueryFor_NonExistentToken();
        }

        string memory imageURI;
        string memory name;
        string memory description;

        if (s_tokenIdToRole[tokenId] == Role.Sasuke_Uchiha) {
            imageURI = s_Sasuke_Uchiha_Uri;
            name = "Sasuke_Uchiha";
            description = "A NFT Of SasukeUchiha";
        } else if (s_tokenIdToRole[tokenId] == Role.Naruto_Uzumaki) {
            imageURI = s_Naruto_Uzumaki_Uri;
            name = "Naruto_Uzumaki";
            description = "A NFT Of NarutoUzumaki";
        } else {
            imageURI = s_Itachi_Uchiha_Uri;
            name = "Itachi_Uchiha";
            description = "A NFT Of ItachiUchiha";
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":',
                            name,
                            ', "description": ',
                            description,
                            '"attributes": [{"trait_type": "Role", "value":',
                            s_value,
                            '}], "image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            );
    }

    //mint角色代表向他投票
    function mint(Role role, address to) external payable {
        require(msg.value >= 0.0001 ether, "Insufficient funds for minting");

        _safeMint(to, s_tokenCounter);
        s_tokenIdToRole[s_tokenCounter] = role;
        emit NFTMinted(msg.sender, to, s_projectId, s_tokenCounter);
        s_tokenCounter++;
    }

    /**********
     *
     * getter
     * setter
     *
     **********
     */

    function getNarutoUzumakiUri() external view returns (string memory) {
        return s_Naruto_Uzumaki_Uri;
    }

    function getSasukeUchihaUri() external view returns (string memory) {
        return s_Sasuke_Uchiha_Uri;
    }

    function getItachiUchihaUri() external view returns (string memory) {
        return s_Itachi_Uchiha_Uri;
    }

    function getTokenCounter() external view returns (uint256) {
        return s_tokenCounter;
    }

    function getProjectId() external view returns (uint256) {
        return s_projectId;
    }

    function setSasukeUchihaUri(string memory uri) external onlyOwner {
        s_Sasuke_Uchiha_Uri = uri;
    }

    function setNarutoUzumakiUri(string memory uri) external onlyOwner {
        s_Naruto_Uzumaki_Uri = uri;
    }

    function setItachiUchihaUri(string memory uri) external onlyOwner {
        s_Itachi_Uchiha_Uri = uri;
    }

    function setValue(string memory value) external onlyOwner {
        s_value = value;
    }

    function setProjectId(uint256 projectId) external onlyOwner {
        s_projectId = projectId;
    }
}
