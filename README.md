# REI-Beacon-Project
Reyes Engineering, Inc. Beacon Project - Client Tracking

## Reyes Engineering
### Beacon Technology Project
### Event triggers based on client location within building

#### The Narrative:
- Client enters through the door, beacon1 (tag: lobby) sends payload via bluetooth to phone
- Phone uses payload to send another payload with location and other info to real-time database
  - Client can also send info about wanting drinks and what kind of drinks
- Real-time API database sends notifications to employee phone/web app along with other information that is useful about the client
- Repeat steps 1-2 when in the elevator and near the front door
  - When in the elevator, dashboard web app updates and shows client info about meeting and options for checking in

#### Application interface:

- Client phone app
- Employee phone app
- Employee web app
- Dashboard web app

#### Status of Project:

- iOS applications: almost done/needs to be published
- Employee app fully functional
- Client app functional, needs beacon monitoring capabilities while app is killed
- Android application: not started
- Web applications: employee app not started/dashboard functional, needs to be published

#### What needs to be completed: 
(0 - cannot do it/need other people —> 10 - completely doable)

- Migration of database from private google account to company google account (8)
- Publishing iOS phone applications (9)
- Maintaining iOS phone applications (10)
- Creating Android applications client/employee (2)
- Creating Employee web app (4)
- Deploying dashboard web app (9)

#### Who is needed:

- Project Manager for Software Development
- UI/UX designer
- Web application developer with experience in React.js
- Software developer with experience in Android development
- Software developer with experience in iOS development
- Backend developer with experience in constructing real-time databases using socket.io or has experience with Firebase

#### Other Important Information/Instructions:
- maintenance of database/application is a must
- maintain database through company google account
- code will be published on private one drive
- if not already done so, place beacons in front door, elevator, lobby
- while dashboard is not published to the internet, I will send IP address daily to show what should be displayed on TV and tablet
- programmers will need to read documentation on application and also need to become familiar with Estimote beacon technology
