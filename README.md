# MethodsCount #
## Service overview ##
MethodsCount is a web service (and API) to help with the task of assessing the size of the Android library ecosystem.
From a simple web interface it's possible to ask for the details of a given Android library, such as:
- the methods count
- the size of the library
- the list of its dependencies
- the references to previous versions that have been already computed

The methods count is useful to understand the influence of the adopted libraries on the total size of the method table, a critical factor for pre-Lollipop Android versions, which still suffer from the old 65k methods limit.

In order to compute this information, we use, at the core, `gradlew`. For more details look at this SO answer
https://stackoverflow.com/questions/17094094/showing-dex-method-count-by-package/35066525#35066525
(full disclosure: its ours).

What's important to know is that the computation for each library is quite CPU intensive, in particular if the dependencies have themselves not been computed yet (it's a recursive procedure). This is also why we try to cache as much as possible (more details soon).

The application has been written in Sinatra + Javascript, supported by a MySQL database.

The web application is entirely written in Javascript (so to uncouple the development of frontend and backend) and it consumes a set of APIs provided by the backend.

The backend is written in Ruby on top of Sinatra. It's been necessary split the app in to services, due to the different resource requirements of serving users (possibly at a big scale) and execute CPU intensive library computation tasks.

The result is a 2 parts backend:
- the frontend serving part, which serves the web page, using already computed content (from MySQL) and forwards the user requests to the background workers
- the background workers, indeed: the receive and compute asynchronously the user requests.

## Amazon Web Service integration ##

The services are running on different EC2 instances (`t2.micro` and `t2.small`), and have different scaling policies.

In order to simplify the operational effort to give shape to our infrastructure and maintain it, we have leveraged Elastic Beanstalk, keeping the database manually configured on RDS in order to be able to share it between the two services.

The frontend-server forwards requests to the background workers using SQS.
The background-workers listen to the queue and process the item in the queue, scaling out into multiple parallel workers in case of demand (the Elasti Beanstalk worker environment helped a lot in setting up the autoscaling policies).
The frontend-server also scales out on demand, serving the user requests through an ELB.

This architecture allowed us keep the interface responsive while the user is waiting for the result to be computed. The waiting is implemented via polling. The frontend-server, once the library computation request has been forwarded to the workers, polls the database for the result.

This approach saved us already once when we experienced a partial outage: the background worker (only one) went out of memory (the library graph computation is also memory intensive), but it wasn't replaced by the autoscaling group (badly configured health check). The website kept working until we noticed the problem and, once the workers were back up, all the pending library requests have been processed. No data loss, user only partially affected (already computed library could still be fetched).

We use a bash script leveraging the aws cli in order to update the sdk we use in the workers. Given that the update takes quite a few resources and time, it would not be ideal to execute it every time a new instance is created. We therefore bake the updated SDK into an Amazon Machine Image and essentially update the Elastic Beanstalk configuration for the EC2 instance.

## Motivation for closing the free online version ##
Please read [this article](https://medium.com/@rotxed/sunsetting-methodscount-com-cb5693a9586).

## How to use it locally ##
### Install dependencies ###
To install the required libraries, run: 
`bundle install`
You then need to manually install the Android SDK and point the environment to the `dx` command line tool, via the following environment variable
```
DX_PATH=<path to 'dx' in Android SDK>
```
### Database configuration ###
Load the dump provided with the repository into your locally running MySql instance.
After that, you can configure the following environment variables to let the application access your DB correctly:
```
RDS_HOSTNAME=<db host, usually localhost when local>
RDS_USERNAME=<db user name>
RDS_PASSWORD=<db password>
RDS_PORT=<db port, usually 3306>
RDS_DB_NAME=<db name>
```
### Run server ###

`bundle exec rackup`

and then point the browser to

`http://localhost:9292`

To see the results, check the response payload in the browser console.
