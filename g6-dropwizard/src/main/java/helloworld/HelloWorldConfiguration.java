package helloworld;

import io.dropwizard.Configuration;
import javax.validation.constraints.NotEmpty;

public class HelloWorldConfiguration extends Configuration {
    @NotEmpty
    public String template;

    @NotEmpty
    public String defaultName = "Stranger";
}
