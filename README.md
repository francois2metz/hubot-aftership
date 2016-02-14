# hubot-aftership

Track your packages using the [aftership API](https://www.aftership.com/docs/api).

See [`src/aftership.coffee`](src/aftership.coffee) for full documentation.

## Install

In hubot project repo, run:

    npm install hubot-aftership --save

Then add **hubot-aftership** to your `external-scripts.json`:

```json
[
  "hubot-aftership"
]
```

## Configuration


- `AFTERSHIP_API_KEY`: Your aftership api key
- `AFTERSHIP_SECRET`: The secret that protect webhook

On aftership side, setup your webhook to: `https://hubot/aftership?secret=YOURSECRET`. Replace your secret by the value of `AFTERSHIP_SECRET`.
