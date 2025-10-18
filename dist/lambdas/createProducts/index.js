"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handler = void 0;
const dynamoClient_1 = require("../../db/dynamoClient");
const uuid_1 = require("uuid");
const handler = async (event) => {
    try {
        const body = JSON.parse(event.body || "{}");
        const product = {
            id: (0, uuid_1.v4)(),
            name: body.name,
            description: body.description,
            price: body.price,
            currency: body.currency || "USD"
        };
        await (0, dynamoClient_1.saveProduct)(product);
        return {
            statusCode: 201,
            body: JSON.stringify(product)
        };
    }
    catch (err) {
        console.error(err);
        return { statusCode: 500, body: "Error creating product" };
    }
};
exports.handler = handler;
//# sourceMappingURL=index.js.map