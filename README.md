# iOS-Lead-Essential

#### EssentialFeed CI Status
![CI-iOS](https://github.com/nikolay-dementiev/iOS-Lead-Essential/actions/workflows/CI-iOS.yml/badge.svg?branch=master)

![CI-macOS](https://github.com/nikolay-dementiev/iOS-Lead-Essential/actions/workflows/CI-macOS.yml/badge.svg?branch=master)

![Deploy](https://github.com/nikolay-dementiev/iOS-Lead-Essential/actions/workflows/Deploy.yml/badge.svg?branch=master)

#### Achievements:

- <img src="https://cdn.essentialdeveloper.com/images/belts/white-belt-1.png" width="14" height="14"/> [White belt 1st Stripe](./Resources/white-belt-1.pdf): <u>**[341ef910-9de2-48df-8351-329f810d69f4](https://academy.essentialdeveloper.com/achievements/341ef910-9de2-48df-8351-329f810d69f4)**</u>
- <img src="https://cdn.essentialdeveloper.com/images/belts/white-belt-2.png" width="14" height="14"/> [White belt 2nd Stripe](./Resources/white-belt-2.pdf): <u>**[a71327d0-2c22-4b13-8b7d-c9cc63c1dddc](https://academy.essentialdeveloper.com/achievements/a71327d0-2c22-4b13-8b7d-c9cc63c1dddc)**</u>
- <img src="https://cdn.essentialdeveloper.com/images/belts/white-belt-3.png" width="14" height="14"/> [White belt 3rd Stripe](./Resources/white-belt-3.pdf): <u>**[88414477-65d9-4062-861c-913e1d47c07d](https://academy.essentialdeveloper.com/achievements/88414477-65d9-4062-861c-913e1d47c07d)**</u>
- <img src="https://cdn.essentialdeveloper.com/images/belts/white-belt-4.png" width="14" height="14"/> [White belt 4th Stripe](./Resources/white-belt-4.pdf): <u>**[ab4f7ea8-ca5a-480e-8aa0-abc737c1a174](https://academy.essentialdeveloper.com/achievements/ab4f7ea8-ca5a-480e-8aa0-abc737c1a174)**</u>
- <img src="https://cdn.essentialdeveloper.com/images/belts/blue-belt.png" width="14" height="14"/> [Blue belt](./Resources/blue-belt): <u>**[8b13bb03-fd74-445b-9833-2bfc3faa5e13](https://academy.essentialdeveloper.com/achievements/8b13bb03-fd74-445b-9833-2bfc3faa5e13)**</u>
- <img src="https://cdn.essentialdeveloper.com/images/ile-logo-t.png" width="14" height="14"/> [Certificate of Completion](./Resources/certificate-of-completion.pdf): <u>**[5b5d1439-d5d8-4d26-a477-4c7bc6eb54f5](https://academy.essentialdeveloper.com/achievements/5b5d1439-d5d8-4d26-a477-4c7bc6eb54f5)**</u>


## Essential Feed App – Image Feed Feature
## BDD Specs

### Story: Customer requests to see their image feed
### Narrative #1
```
As an online customer
I want the app to automatically load my latest image feed
So I can always enjoy the newest images of my friends
```
#### Scenarios (Acceptance criteria)
```
Given the customer has connectivity
 When the customer requests to see their feed
 Then the app should display the latest feed from remote
  And replace the cache with the new feed
```
### Narrative #2
```
As an offline customer
I want the app to show the latest saved version of my image feed
So I can always enjoy images of my friends
```
#### Scenarios (Acceptance criteria)
```
Given the customer doesn't have connectivity
  And there’s a cached version of the feed
  And the cache is less than seven days old
 When the customer requests to see the feed
 Then the app should display the latest feed saved
Given the customer doesn't have connectivity
  And there’s a cached version of the feed
  And the cache is seven days old or more
 When the customer requests to see the feed
 Then the app should display an error message
Given the customer doesn't have connectivity
  And the cache is empty
 When the customer requests to see the feed
 Then the app should display an error message
```
## Use Cases
### Load Feed From Remote Use Case
#### Data:
- URL
#### Primary course (happy path):
1. Execute "Load Image Feed" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates image feed from valid data.
5. System delivers image feed.
#### Invalid data – error course (sad path):
1. System delivers invalid data error.
#### No connectivity – error course (sad path):
1. System delivers connectivity error.
---
### Load Feed Image Data From Remote Use Case
#### Data:
- URL
#### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System delivers image data.
#### Cancel course:
1. System does not deliver image data nor error.
#### Invalid data – error course (sad path):
1. System delivers invalid data error.
#### No connectivity – error course (sad path):
1. System delivers connectivity error.
---
### Load Feed From Cache Use Case
#### Primary course:
1. Execute "Load Image Feed" command with above data.
2. System retrieves feed data from cache.
3. System validates cache is less than seven days old.
4. System creates image feed from cached data.
5. System delivers image feed.
#### Retrieval error course (sad path):
1. System delivers error.
#### Expired cache course (sad path): 
1. System delivers no feed images.
#### Empty cache course (sad path): 
1. System delivers no feed images.
---
### Load Feed Image Data From Cache Use Case
#### Data:
- URL
#### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System retrieves data from the cache.
3. System delivers cached image data.
#### Cancel course:
1. System does not deliver image data nor error.
#### Retrieval error course (sad path):
1. System delivers error.
#### Empty cache course (sad path):
1. System delivers not found error.
---
### Validate Feed Cache Use Case
#### Primary course:
1. Execute "Validate Cache" command with above data.
2. System retrieves feed data from cache.
3. System validates cache is less than seven days old.
#### Retrieval error course (sad path):
1. System deletes cache.
#### Expired cache course (sad path): 
1. System deletes cache.
---
### Cache Feed Use Case
#### Data:
- Image Feed
#### Primary course (happy path):
1. Execute "Save Image Feed" command with above data.
2. System deletes old cache data.
3. System encodes image feed.
4. System timestamps the new cache.
5. System saves new cache data.
6. System delivers success message.
#### Deleting error course (sad path):
1. System delivers error.
#### Saving error course (sad path):
1. System delivers error.
---
### Cache Feed Image Data Use Case
#### Data:
- Image Data
#### Primary course (happy path):
1. Execute "Save Image Data" command with above data.
2. System caches image data.
3. System delivers success message.
#### Saving error course (sad path):
1. System delivers error.
---
## Flowchart
![Feed Loading Feature](feed_flowchart.png)
## Architecture
![Feed Loading Feature](feed_architecture.png)
## Model Specs
### Feed Image
| Property      | Type                |
|---------------|---------------------|
| `id`          | `UUID`              |
| `description` | `String` (optional) |
| `location`    | `String` (optional) |
| `url`	        | `URL`               |
### Payload contract
```
GET *url* (TBD)
200 RESPONSE
{
	"items": [
		{
			"id": "a UUID",
			"description": "a description",
			"location": "a location",
			"image": "https://a-image.url",
		},
		{
			"id": "another UUID",
			"description": "another description",
			"image": "https://another-image.url"
		},
		{
			"id": "even another UUID",
			"location": "even another location",
			"image": "https://even-another-image.url"
		},
		{
			"id": "yet another UUID",
			"image": "https://yet-another-image.url"
		}
		...
	]
}
```
