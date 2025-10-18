import { APIGatewayProxyHandler } from "aws-lambda";
import { getAllProducts } from "../../db/dynamoClient";

export const handler: APIGatewayProxyHandler = async () => {
  try {
    const products = await getAllProducts();
    return {
      statusCode: 200,
      body: JSON.stringify(products)
    };
  } catch (err) {
    console.error(err);
    return { statusCode: 500, body: "Error fetching products" };
  }
};
