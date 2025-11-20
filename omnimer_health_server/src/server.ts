import dotenv from "dotenv";
dotenv.config();

import app from "./app";

const PORT: number = parseInt(process.env.PORT || "5000", 10);

app.listen(PORT, "0.0.0.0", () => {
  console.log(
    `Server is running on http://localhost:${PORT} in ${process.env.NODE_ENV} mode`
  );
  console.log(`Swagger Docs: http://localhost:${PORT}/api-docs`);
});
