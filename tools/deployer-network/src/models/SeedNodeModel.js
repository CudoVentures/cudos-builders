const AbsNodeModel = require('./AbsNodeModel');

class SeedNodeModel extends AbsNodeModel {

    constructor() {
        super();
        this.validatorId = "";
    }

    getDockerContainerInitName() {
        return `cudos-init-seed-node-${this.nodeId}`;
    }

    getDockerContainerStartName() {
        return `cudos-start-seed-node-${this.nodeId}`;
    }

    static fromJson(json) {
        if (json === null) {
            return null;
        }

        const model = AbsNodeModel.fromJson(json, new SeedNodeModel());

        model.validatorId = json.validatorId ?? model.validatorId;

        return model;
    }

}

module.exports = SeedNodeModel;