import dotenv from 'dotenv';
import path from 'path';

export default function getIbcConfig() {
    const __dirname = path.resolve(path.dirname('')); 

    let envPath = path.join(__dirname, '/config/ibc-test.env');

    const result = dotenv.config({ path: envPath });

    if (result.error) {
        console.error(__dirname);
        throw result.error;
    }

    // required environment variables
    const envVariables = [
        'CHAIN_ID_2',
        'REST_2',
        'GAS_PRICE_2',
        'MNEMONIC_2',
        'IBC_MODULE_ADDRESS_1',
        'IBC_MODULE_ADDRESS_2',
        'PORT_1',
        'PORT_2',
        'CHANNEL_1',
        'CHANNEL_2',
        'IBC_DENOM_1',
        'IBC_DENOM_2',
        'NUMBER_OF_ADDRESSES',
        'NUMBER_OF_TESTS',
        'MAX_ACUDOS_PER_ADDRESS',
    ];

    envVariables.forEach((envVariable) => {
        if (!process.env[envVariable]) {
            throw new Error(`Environment variable ${envVariable} is missing`);
        }
    });


    return {
        NETWORK_1: {
            IBC_MODULE_ADDRESS: process.env.IBC_MODULE_ADDRESS_1,
            PORT: process.env.PORT_1,
            CHANNEL: process.env.CHANNEL_1,
            IBC_DENOM: process.env.IBC_DENOM_1,
        },
        NETWORK_2: {
            CHAIN_ID: process.env.CHAIN_ID_2,
            REST: process.env.REST_2,
            GAS_PRICE: process.env.GAS_PRICE_2,
            MNEMONIC: process.env.MNEMONIC_2,
            IBC_MODULE_ADDRESS: process.env.IBC_MODULE_ADDRESS_2,
            PORT: process.env.PORT_2,
            CHANNEL: process.env.CHANNEL_2,
            IBC_DENOM: process.env.IBC_DENOM_2,
        },
        TEST: {
            NUMBER_OF_TESTS: process.env.NUMBER_OF_TESTS,
            NUMBER_OF_ADDRESSES: process.env.NUMBER_OF_ADDRESSES,
            MAX_ACUDOS_PER_ADDRESS: process.env.MAX_ACUDOS_PER_ADDRESS,
        }
    }
}