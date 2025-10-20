export class HttpError extends Error {
  status: number;
  code?: string;
  details?: any;

  constructor(
    status: number,
    message: string,
    options?: { code?: string; details?: any }
  ) {
    super(message);
    this.status = status;
    if (options) {
      this.code = options.code;
      this.details = options.details;
    }

    // Giữ stack trace đúng khi kế thừa từ Error
    Object.setPrototypeOf(this, HttpError.prototype);
  }

  toJSON() {
    return {
      success: false,
      status: this.status,
      message: this.message,
      code: this.code,
      details: this.details,
    };
  }
}
