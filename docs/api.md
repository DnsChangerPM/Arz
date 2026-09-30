# Data API

Production uses the public [Tomanify JSON feed](https://github.com/rate-json/default), fetched from its raw GitHub `data.json`. It publishes free-market reference values directly in **toman**, 3–4 times daily, without a key. Attribution is required; commercial use requires contacting its maintainer. The app therefore does not multiply these values by ten. If a future adapter accepts IRR, it must divide IRR by 10 exactly once before creating `CurrencyRate`.

Current payload: `generated_by_tomanify_at` and `values` keyed by ISO code. USD and EUR are mandatory; malformed, non-positive, implausibly large, or missing required values reject the whole update. Tomanify directly provides USD, EUR, AED, TRY and CNY. GBP is marked as derived and calculated from the Tomanify free-market USD anchor divided by the public ExchangeRate-API USD→GBP reference cross-rate. If that secondary call fails, GBP is omitted rather than fabricated.

The feed is not real-time and has no published SLA or numeric rate limit. The client refreshes at most every 15 minutes, caches the latest valid response, retries transient failures with exponential delay, and labels source/type/date. Replace `ExchangeRateRemoteDataSource` to migrate providers. URLs are supplied through `--dart-define`.
