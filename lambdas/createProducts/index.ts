import { APIGatewayProxyHandler } from "aws-lambda";
import { saveProduct } from "../../db/dynamoClient";
import { v4 as uuidv4 } from "uuid";

export const handler: APIGatewayProxyHandler = async (event) => {
  try {
    const body = JSON.parse(event.body || "{}");
    const product = {
      id: uuidv4(),
      name: body.name,
      description: body.description,
      price: body.price,
      currency: body.currency || "USD"
    };

    await saveProduct(product);

    return {
      statusCode: 201,
      body: JSON.stringify(product)
    };
  } catch (err) {
    console.error(err);
    return { statusCode: 500, body: "Error creating product" };
  }
};
