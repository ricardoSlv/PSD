package helloworld.resources;

import helloworld.api.Saying;

import java.util.Optional;

import javax.ws.rs.GET;
import javax.ws.rs.PUT;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.PathParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/hello")
@Produces(MediaType.APPLICATION_JSON)
public class HelloWorldResource {
    private final String template;
    private volatile String defaultName;
    private long counter;

    public HelloWorldResource(String template, String defaultName) {
        this.template = template;
        this.defaultName = defaultName;
    }

    @GET
    public Saying sayHello(@QueryParam("name") Optional<String> name) {
        final String content = String.format(template, name.orElse(defaultName));

        // concurrent requests can invoke sayHello
        synchronized (this) {
            // demo only; if counter is resource state, GET should not increment it
            counter++;
            return new Saying(counter, content);
        }
    }

    @PUT
    @Path("/default/{name}")
    public Response put(@PathParam("name") String name) {
        defaultName = name;
        return Response.ok().build();
    }

    @POST
    @Path("/add/{n}")
    public Response add(@PathParam("n") String val) {
        int n = Integer.parseInt(val);
        synchronized (this) { counter += n; }
        return Response.ok().build();
    }

}

