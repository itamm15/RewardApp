# Rewardapp

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

If you want to visit sites by your own, here are vailable routs:

* "/admin"
* "/main"
* "/"
* "/add"
* "/add/:id"
* "/admin/delete/:id"
* "/mailbox" - to see mails, firstly log in and grant some points. Then redirect into /mailbox to see mail. 


To log into, firstly import database, or add users into database. 

E.g. INSERT INTO users (name, surname, role, mail) VALUES ('mat', 'osi', 'member', 'osinski.mateusz15@gmail.com') 

* NAME MUST BE UNIQUE!

# LOGING INTO

* To log in as member, just type member name
* To log in as admin, just type admin 

# The authentication is just related on the user name, which by default is treated as unique value. 
