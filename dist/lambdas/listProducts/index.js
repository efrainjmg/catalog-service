"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handler = void 0;
const dynamoClient_1 = require("../../db/dynamoClient");
const handler = async () => {
    try {
        const products = await (0, dynamoClient_1.getAllProducts)();
        return {
            statusCode: 200,
            body: JSON.stringify(products)
        };
    }
    catch (err) {
        console.error(err);
        return { statusCode: 500, body: "Error fetching products" };
    }
};
exports.handler = handler;
//# sourceMappingURL=index.js.map