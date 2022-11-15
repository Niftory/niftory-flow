# Niftory NFTS

Niftory provides rich APIs for minting and management of NFTs while abstracting away the new (and currently evolving) complexities introduced by blockchain technologies. Because these APIs are standardized and blockchain-agnostic, project owners may 

These complexities become more difficult to manage when trying to build a unified interface for multiple different chains, each with their own unique quirks. 

In order to gain a better understand of Niftory's solution, this document outlines a common data model adopted by all smart contracts deployed by Niftory, regardless of blockchain. We will review different stakeholders, what capabilities they have to interact with the NFTs, and specific features and implementation details for each supported blockchain.

- [Definitions](#definitions)
- [Core Architecture](#core-architecture)
  - [Contract layer](#contract-layer)
  - [Set layer](#set-layer)
  - [Template layer](#template-layer)
- [Minting](#minting)
- [Mutable Metadata](#mutable-metadata)
- [Stakeholders and Capabilities](#stakeholders-and-capabilities)
  - [Admins](#admins)
  - [Set Owners](#set-owners)
  - [Collectors](#collectors)

## Definitions



## Core Architecture

There are three layers to Niftory's smart contract architecture:
* Contract
* Set
* Template

### Contract layer

Every NFT project begins with a smart contract implementation of a standardized NFT interface for some blockchain. When deployed, it will likely be associated to a uniquely identifiable account. Because many NFT 

### Set layer

Sets allow NFT project administrators to add some organizational structure to minted NFTs, while keeping the same branding. Each contract can contain many sets, and access to those sets 

### Template layer

## Minting

## Mutable Metadata

## Stakeholders and Capabilities

### Admins

### Set Owners

### Collectors 

