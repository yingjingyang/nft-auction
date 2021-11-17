import { BigInt, Address } from "@graphprotocol/graph-ts";
import {
  Contract,
  Approval,
  ApprovalForAll,
  Transfer,
} from "../generated/Contract/Contract";
import { Token } from "../generated/schema";

const zeroAddr = Address.fromHexString("0x0");
const auctionAddr = Address.fromHexString(
  "0x0789fE88eb35282ADa8c2121Fa962856013cc3d9"
);

export function handleApproval(event: Approval): void {}

export function handleApprovalForAll(event: ApprovalForAll): void {}

export function handleTransfer(event: Transfer): void {
  let id = event.params.tokenId.toHex();
  let to = event.params.to;
  let tokenId =  event.params.tokenId;
  let token = Token.load(id);
  if (token == null) {
    token = new Token(id);
    token.tokenId = tokenId;
  }

  if ( to == zeroAddr ){
    token.isBurn = true;
  }else{
    token.isBurn = false;
  }
  
  if( to == auctionAddr ){
    token.isAuction = true;
  }else{
    token.isAuction = false;
  }

  token.owner = to;

  token.save();
}
