# Private Members Area App

This is a website which has a members-only area. Members pay a monthly fee using Strip to join. Inside the area there will be TBD that those users will want to pay for (something like Patreon).

The app will have a home page with a description of what's behind the paywall. People can login/subscribe. After they login, the logged in user will see content of some sort that can be purchased?

## Setup

1. Same setup as with other lessons that require Next.js, Tailwind, Prisma, and NextAuth.js.
2. Setup the .env file with the following email and auth (repeating here for reference):

```
EMAIL_SERVER=smtp://user:pass@smtp.mailtrap.io:465
EMAIL_FROM=Your name <you@email.com>
NEXTAUTH_URL=http://localhost:3000
SECRET=<ENTER A UNIQUE STRING HERE>
```

3. Add 'pages/api/auth/[...nextauth].js' as we have done in the past.
4. Add the usual 4 schemas to schema.prisma and run the migration:

```
npx prisma migrate dev
```

5. Add the 'SessionProvide' wrapper to '\_apps.js':

```
import { SessionProvider } from 'next-auth/react'
.....

return (
	<SessionProvider session={pageProps.session}>
	  <Component {...pageProps} />
	</SessionProvider>
)
```

6. Refactor 'index.js' to contain minimal content:

```
import Head from 'next/head'

export default function Home() {
  return (
    <div>
      <Head>
        <title>Blog</title>
        <meta name='description' content='Blog' />
        <link rel='icon' href='/favicon.ico' />
      </Head>

      <h1>Welcome!</h1>
    </div>
  )
}
```

## Create the Home Page

1. Refactor the home page to provide some content about the private membership area.

## Implement Authentication

1. As with other projects, we'll point members to '/api/auth/signin'. Change the link that allows a user to become a supporter to use this API (currently it's a '#'). I use the 'next/link' to eliminate warnings.
2. Once logged in, we'll have a 'session' which can then use to direct the user to the 'members' page.
3. In 'pages/members.js', if there is no session, the user is redirected back to the home page. And likewise, in 'pages/index.js', if there IS a session, the user is redirected to the 'members' page.

## Detect User as Subscriber

1. Update the schema to track whether the user is a subscriber (and run 'migrate').
2. In 'pages/api/auth/[...nextauth].js', return the new subscriber flag in the 'callback' - this allows the 'isSubscriber' flag to be accessible with the session data.
3. In the 'pages/members.js', if the user isn't a subscriber, redirect them to a new page, 'pages/join.js'.
