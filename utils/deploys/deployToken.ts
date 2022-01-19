import { Signer } from "ethers";
import { BigNumber } from "@ethersproject/bignumber";
import { Address } from "../types";
import {
  DoubloonPowah,
  DoubloonToken,
  MerkleDistributor,
  OtcEscrow,
  Vesting,
  FTCVesting,
} from "../contracts";

import { DoubloonToken__factory } from "../../typechain/factories/DoubloonToken__factory";
import { MerkleDistributor__factory } from "../../typechain/factories/MerkleDistributor__factory";
import { Vesting__factory } from "../../typechain/factories/Vesting__factory";
import { OtcEscrow__factory } from "../../typechain/factories/OtcEscrow__factory";
import { FTCVesting__factory } from "../../typechain/factories/FTCVesting__factory";
import { DoubloonPowah__factory } from "@typechain/factories/DoubloonPowah__factory";

export default class DeployToken {
  private _deployerSigner: Signer;

  constructor(deployerSigner: Signer) {
    this._deployerSigner = deployerSigner;
  }

  public async deployDoubloonToken(initialAccount: Address): Promise<DoubloonToken> {
    return await new DoubloonToken__factory(this._deployerSigner).deploy(initialAccount);
  }

  public async deployMerkleDistributor(
    token: Address,
    merkleRoot: string,
  ): Promise<MerkleDistributor> {
    return await new MerkleDistributor__factory(this._deployerSigner).deploy(token, merkleRoot);
  }

  public async deployVesting(
    token: Address,
    recipient: Address,
    vestingAmount: BigNumber,
    vestingBegin: BigNumber,
    vestingCliff: BigNumber,
    vestingEnd: BigNumber,
  ): Promise<Vesting> {
    return await new Vesting__factory(this._deployerSigner).deploy(
      token,
      recipient,
      vestingAmount,
      vestingBegin,
      vestingCliff,
      vestingEnd,
    );
  }

  public async deployOtcEscrow(
    beneficiary: Address,
    dblGov: Address,
    vestingStart: BigNumber,
    vestingCliff: BigNumber,
    vestingEnd: BigNumber,
    usdcAmount: BigNumber,
    dblAmount: BigNumber,
    usdcAddress: Address,
    dblAddress: Address,
  ): Promise<OtcEscrow> {
    return await new OtcEscrow__factory(this._deployerSigner).deploy(
      beneficiary,
      dblGov,
      vestingStart,
      vestingCliff,
      vestingEnd,
      usdcAmount,
      dblAmount,
      usdcAddress,
      dblAddress,
    );
  }

  public async deployFtcVesting(
    dbl: Address,
    recipient: Address,
    treasury: Address,
    vestingAmount: BigNumber,
    vestingBegin: BigNumber,
    vestingCliff: BigNumber,
    vestingEnd: BigNumber,
  ): Promise<FTCVesting> {
    return await new FTCVesting__factory(this._deployerSigner).deploy(
      dbl,
      recipient,
      treasury,
      vestingAmount,
      vestingBegin,
      vestingCliff,
      vestingEnd,
    );
  }

  public async deployDoubloonPowah(
    owner: Address,
    dblToken: Address,
    uniPair: Address,
    sushiPair: Address,
    masterChef: Address,
    masterChefId: BigNumber,
    farms: Address[],
    vesting: Address[],
  ): Promise<DoubloonPowah> {
    return await new DoubloonPowah__factory(this._deployerSigner).deploy(
      owner,
      dblToken,
      uniPair,
      sushiPair,
      masterChef,
      masterChefId,
      farms,
      vesting,
    );
  }
}
