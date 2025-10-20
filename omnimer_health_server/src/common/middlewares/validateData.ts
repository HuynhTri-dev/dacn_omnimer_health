// src/middlewares/validateData.ts
import { Request, Response, NextFunction } from "express";
import { z, ZodError, ZodSchema } from "zod";
import { HttpError } from "../../utils/HttpError";
import chalk from "chalk";

interface ValidationSchemas {
  body?: ZodSchema<any>;
  query?: ZodSchema<any>;
  params?: ZodSchema<any>;
  headers?: ZodSchema<any>;
}

function removeEmpty(obj: Record<string, any>) {
  return Object.fromEntries(
    Object.entries(obj).filter(
      ([_, v]) => v !== null && v !== "" && v !== undefined
    )
  );
}

export const validateData = (schemas: ValidationSchemas) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    try {
      console.log(chalk.green("[ValidateData]"), {
        body: req.body,
        query: req.query,
        params: req.params,
      });

      if (schemas.body) {
        req.body = schemas.body.parse(removeEmpty(req.body));
      }

      if (schemas.query) {
        req.query = schemas.query.parse(req.query);
      }

      if (schemas.params) {
        req.params = schemas.params.parse(req.params);
      }

      if (schemas.headers) {
        const parsedHeaders = schemas.headers.parse({
          authorization: req.headers["authorization"],
        });
        (req as any).authHeader = parsedHeaders.authorization;
      }

      next();
    } catch (error) {
      if (error instanceof ZodError) {
        next(
          new HttpError(400, "Invalid input data", {
            details: error.issues.map((i) => ({
              path: i.path,
              msg: i.message,
            })),
            code: "VALIDATION_ERROR",
          })
        );
      }

      return next(new HttpError(500, "Internal server error"));
    }
  };
};
