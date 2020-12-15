package helloworld;

import io.dropwizard.Application;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;

import helloworld.resources.HelloWorldResource;
import helloworld.health.TemplateHealthCheck;

public class HelloWorldApplication extends Application<HelloWorldConfiguration> {

    public static void main(final String[] args) throws Exception {
        new HelloWorldApplication().run(args);
    }

    @Override
    public String getName() {
        return "HelloWorld";
    }

    @Override
    public void initialize(final Bootstrap<HelloWorldConfiguration> bootstrap) {
    }

    @Override
    public void run(final HelloWorldConfiguration configuration,
                    final Environment environment) {
        environment.jersey().register(
            new HelloWorldResource(configuration.template, configuration.defaultName));
        environment.healthChecks().register("template",
            new TemplateHealthCheck(configuration.template));
    }

}
