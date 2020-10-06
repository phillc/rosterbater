# Rosterbater

## Installation

- Clone this repository.
- Create yahoo app, with API permissions for Fantasy Sports, and OpenID Connect https://developer.yahoo.com/apps/ . For an easier authentication workflow, set the domain to `rosterbater.test`.
- Add yahoo key, and yahoo secret to the environment.
  - This project uses dot env, so one way to achieve that is to copy .env.example to .env in the server dirextory and fill them out there.
- To retrieve player data, add your yahoo uid to the environment.
  - Should only be necessary for draft related tools.
  - You can get your uid by leaving it blank, starting the app, sign in with yahoo, then running `rails runner 'puts User.first.yahoo_uid'` or `docker-compose run app rails runner 'puts User.first.yahoo_uid'`.
  - This enables the Game Admin page in the top navigation.
    - Sync players retrieves player data from yahoo.

To run the app, run `docker-compose up`.

# Test domain

The yahoo api requires an https url.

I suggest you add `127.0.0.1 rosterbater.test` to your `/etc/hosts` file. Traefik is configured to create a locally signed ssl cert to serve `https://rosterbater.test`. 

## Notes

- The administative side of this site can be extremely frustrating... for example to populate the games, you have to log in. When you login, there are no games, so it blows up.
- There are remains of old ideas I had scattered through the code base. Things like bringing in vegas odds to create your own rankings. Doubt I'll ever get to it, but I don't doubt there exists some dead code.
- I did not want to pay for extra dynos while on heroku, so many operations that should be backgrounded are done inline to the web request. Hopefully this can be addressed some day.
- This UI is feels old.

## Contribution

Fork, and do your work. Any work on the server side must include specs.
