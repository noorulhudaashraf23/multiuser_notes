 
 In Progress
 in app notifications / push notifications / broadcast notifications to users while adding them as a collaborators
 FCM Token
 Firebase Cloud Messaging 
 Continue from => we have to store fcm token for every user and send notification particular to a user using app and for this we have to create deno + TS function (edge func)




 Pending

 notifications via email using supabase edge functions
 edge functions are the simple Deno + TypeScript functions to perform a set of task or a single task on demand or when we invoke them from our frontend (web or mobile)
 we call these functions whenever we want and those functions run on supabase (server or cloud) instead of running inside our app

 ik single email can take about 2.5 sec to 10 sec 
 5sec/email
 1min/12emails
 60min/720emails
 
Client => Flutter App
Server (Supabase as Server) <=> (also has/have databases)
Authenticate or Authorize => RLS


