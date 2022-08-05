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
5. Add the 'SessionProvide' wrapper to '_apps.js':
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