import { z } from "zod"

namespace FlowHttp {
  export type Method = "GET" | "POST"

  export type Request<Params> = {
    method: Method
    path: (params: Params) => string
    body?: (params: Params) => object
  }

  const trimTrailingSlash = (baseUrl: string) =>
    baseUrl.endsWith("/") ? baseUrl.slice(0, -1) : baseUrl

  const addLeadingSlash = (path: string) =>
    path.startsWith("/") ? path : "/" + path

  const sendRequest = <Params>(
    request: Request<Params>,
    baseUrl: string,
    params: Params,
  ) => {
    const url =
      trimTrailingSlash(baseUrl) + addLeadingSlash(request.path(params))
    const body = request.body ? request.body(params) : undefined
    const options = {
      method: request.method,
      body: JSON.stringify(body),
      headers: {
        "Content-Type": "application/json",
      },
    }
    return fetch(url, options)
  }

  export type Failure = {
    tag: "failure"
    code: number
    message: string
  }

  export type Success<Body> = {
    tag: "success"
    code: number
    message: string
    body: Body
  }

  export type Response<Body> = Success<Body> | Failure

  const parseErrorBody = z.object({
    code: z.number(),
    message: z.string(),
  }).safeParse

  const getResponseJson = (response: globalThis.Response) =>
    response.json().catch(() => null)

  const processResponse = async <Body>(
    responsePromise: Promise<globalThis.Response>,
    parseBody: (body: any) => Body,
  ): Promise<Response<Body>> => {
    let response: globalThis.Response
    try {
      response = await responsePromise
    } catch (error: any) {
      return {
        tag: "failure",
        code: -1,
        message: error.toString(),
      }
    }
    const body = await getResponseJson(response)
    if (response.ok)
      return {
        tag: "success",
        code: response.status,
        message: response.statusText,
        body: parseBody(body),
      }
    const errorBody = parseErrorBody(body)
    return {
      tag: "failure",
      code: errorBody.success ? errorBody.data.code : response.status,
      message: errorBody.success ? errorBody.data.message : response.statusText,
    }
  }

  export type Handler<Params, Body> = (
    baseUrl: string,
  ) => (params: Params) => Promise<Response<Body>>

  export const createHandler =
    <Params>(request: Request<Params>) =>
    <Body>(parseBody: (body: any) => Body): Handler<Params, Body> =>
    (baseUrl: string) =>
    (params: Params) => {
      const responsePromise = sendRequest(request, baseUrl, params)
      return processResponse(responsePromise, parseBody)
    }
}

export { FlowHttp }
