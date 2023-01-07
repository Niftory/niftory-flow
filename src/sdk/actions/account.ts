import { z } from 'zod'

type AccountRequest = {
  address: string
}

const accountResponseParser = z.object({
  address: z.string(),
})

type AccountResponse = z.TypeOf<typeof accountResponseParser>

const parseAccountResponse = (
  request: AccountRequest,
): Promise<AccountResponse> => {
  accountResponseParser.parse(request)
}
