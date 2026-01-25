export default {
  async fetch(
    _req: Request,
    _env: unknown,
    _ctx: ExecutionContext,
  ): Promise<Response> {
    return new Response("Hello World!", {
      status: 200,
      headers: { "content-type": "text/plain; charset=utf-8" },
    });
  },
};
