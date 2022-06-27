@isTest
global class OrderHttpMockResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"AccountNumber" : ""}');
        res.setStatusCode(200);
        return res;
    }
}