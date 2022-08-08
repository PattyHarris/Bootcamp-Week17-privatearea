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

## Add Stripe Subscriptions

1. This time, using Stripe, we create a test subscription product. From the Stripe dashboard, click on 'Add a Product'.
   1. Set the name to 'Private area subscription'.
   2. The pricing model, uses the 'Standard pricing' with a price of $5.00 and 'recurring'. The billing period is 'Monthly'. Click 'Save Product'.
   3. This gives you a 'API ID' which we'll copy to the .env:
   ```
   STRIPE_PRICE_ID=price_************YOUR VALUE****
   ```
2. Add the other Stripe keys (that we've added before):

```
STRIPE_PUBLIC_KEY=pk_test_YOUR_KEY
STRIPE_SECRET_KEY=sk_test_YOUR_KEY
BASE_URL=http://localhost:3000
```

3. Install the Stripe libraries:

```
npm i @stripe/react-stripe-js @stripe/stripe-js stripe
```

4. In 'pages/join.js', add a button to create a new subscription. When the user clicks the button we’ll send a request to an API endpoint we’ll use to initialize the Stripe purchase:

```
         className="mt-10 bg-black text-white px-5 py-2"
          onClick={async () => {
            const res = await fetch("/api/stripe/session", {
              method: "POST",
            });

            const data = await res.json();
          }}
```

5. The endpoint is handled by 'pages/api/stripe/session.js' - which we've worked with before. Again, this time I added the following to .eslintrc.json to fix the warnings:

```
{
  "extends": "next/core-web-vitals",
  "rules": {
    "@next/next/no-img-element": "off",
    "import/no-anonymous-default-export": "off" <===== FIX
  }
}

```

This time too, instead of using webhooks as in the digital downloads project, we also pass a client_reference_id parameter which stores our user ID, so we know “who made what”. The 'CHECKOUT_SESSION_ID' will be filled in by Stripe when control is returned back to us:

```
....
  const stripe_session = await stripe.checkout.sessions.create({
    billing_address_collection: "auto",
    line_items: [
      {
        price: process.env.STRIPE_PRICE_ID,
        quantity: 1,
      },
    ],
    mode: "subscription",
    success_url:
      process.env.BASE_URL + "/success?session_id={CHECKOUT_SESSION_ID}",
    cancel_url: process.env.BASE_URL + "/cancelled",
    client_reference_id: session.user.id,  <======= No webhook needed
  });

....
```

6. The session ID is returned back to the client - this is then used to send the user to the actual Stripe payment dashboard.
7. In 'pages/join.js', add the script to load the Stripe library:

```
<Script src='https://js.stripe.com/v3/' />
```

Once we return back from the POST, we'll use the session ID (as mentioned in the last step) to redirect the user to checkout.

8. After payment is completed, the user is sent to the '/success' page - this includes the session ID mentioned above. And as we did before, we need to access the session ID server-side - ths bit has never been explained well but we need to import 'next/router' to gave access to the query parameters in 'getServerSideProps' - although props is returned as an empty object....

```
export async function getServerSideProps(context) {
  // This is needed since the router query data is not available client-side.
  // See https://nextjs.org/docs/api-reference/next/router#router-object
  return {
    props: {},
  };
}
```

9. To 'pages/success.js', add a 'useEffect' call to trigger an API request to the endpoint '/api/stripe/success'. We pass the session ID into that POST request.
10. The endpoint above is handled by 'pages/api/stripe/success.js'. Here the session ID is used to retrieve the 'client_reference_id'. We can then update the 'isSubscriber' flag in the database using the latter client ID.
11. Assuming no problems returned in 'pages/success.js', the user is then redirected back to the 'pages/members.js'. Here, we're forcing the page to reload (meaning we don't use router.push() ) - otherwise, we wouldn't see that the user is now a subscriber.
12.
