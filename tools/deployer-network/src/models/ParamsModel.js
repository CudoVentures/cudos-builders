class ParamsModel {

    constructor() {
        this.gravity = new ParamsGravityModel();
    }

    static fromJson(json) {
        if (json === null) {
            return null;
        }

        const model = new ParamsModel();

        model.gravity.ethrpc = json.gravity.ethrpc ?? model.gravity.ethrpc;
        model.gravity.contractDeploerEthPrivKey = json.gravity.contractDeploerEthPrivKey ?? model.gravity.contractDeploerEthPrivKey;

        return model;
    }

}

class ParamsGravityModel {

    constructor() {
        this.ethrpc = "";
        this.contractDeploerEthPrivKey = "";
    }

}

module.exports = ParamsModel;