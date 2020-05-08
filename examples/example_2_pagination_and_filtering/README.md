# Pagination and filtering (the GET params)

I'm gonna give some examples how to approach pagination and filtering.
By this I meas a GET requests' params.

Common mistakes are that they are handled without validation, leading
to random app failures. Usually 500 errors.

Often these params are not provided directly by users. The are results of some redirections.
So we can say, that wee don't need to validate them, because our app will always redirect properly.

IMO this is a mistake.
 
We don't always control them. Eg: 
  - external page can redirect to our app - eg in Wimdu affiliate pages were redirecting to the search results
  - users can copy-paste urls to pass them around and the url can get damaged - eg user copy only part of the url, omitting a half of the params 
  - in emails users received, there can be urls, which can get outdated - eg some params changed in the app
  - users can experiment with the website typing random params in the url - ok we don't want these kind of users, but still - it shouldn't cause 500 errors, because if it happens, developer waste time investigating it as a 500.
  
So it's a good practice to handle these params properly.

### Examples

- pagination: 
- - ?page=2
- - ?page=2&limit=10

- searching
- - ?search=urlencoded-search-phrase

- filtering by tags
- - ?tags[]=abc&tags[]=cde

- filtering by date period
- - ?start_date=2020-10-10&end_date=2020-10-15

- combinations of all the above
- - ?page=2&limit=10&search=search-phrase&tags[]=abc&tags[]=cde&start_date=2020-10-10&end_date=2020-10-15

### Two approaches

I found 2 sensible approaches of handling invalid GET params:

1. If any of the params is invalid, redirect to the page, trimming the invalid param.

eg 

Requesting

?page=2&limit=aaa

would redirct to

?page=2

Use this approach on server-generated-html sites - so that the user is just redirected (with maybe optional flash message). 

2. If any of the params are invalid, render 4** status showing error messages.

eg

?page=2&limit=aaa

returns a 422 response with body:

{
  description: 'Invalid params',
  content: {
    limit: 'Limit needs to be a number'
  }
}

Use this one on API - so that client (eg js app) can see precise information what's wrong with the request.

### Architecture

The app should process the request with invalid params.

In order to implement it in the Rails apps, the GET params needs to be validated as soon as they enter the controller.

So that on invalid params we can redirect or render 4** without further processing the request.   

In the lib/ dir there are some examples.
