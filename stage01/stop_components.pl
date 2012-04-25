#!/usr/bin/perl

require "ec2ops.pl";

parse_input();
print "SUCCESS: parsed input\n";

setlibsleep(0);
print "SUCCESS: set sleep time for each lib call\n";

setremote($masters{"CLC"});
print "SUCCESS: set remote CLC: masterclc=$masters{CLC}\n";

# Sort component keys
%component_roles = ( "NC" => [],
           "CC" => [],
           "SC" => [],
           "WS" => [],
           "CLC" => [] );

foreach my $key (keys %masters) {
  print "Found $key in masters"; 
  foreach my $r (keys %component_roles) {
    if ($key =~ /^$r/) {
      push(@{$component_roles{$r}}, $key);
      print "Adding $key to $r\n";
      last;
    }
  }
}

foreach $r ("NC", "CC", "SC", "WS", "CLC") {
  foreach $component (@{$component_roles{$r}}) {
    if ( exists $slaves{$component} ) {
        print "Stopping $component SLAVE\n";
        control_component_script("STOP", $component, "SLAVE");
    }
    print "Stopping $component MASTER\n";
    control_component_script("STOP", $component, "MASTER");
  }
}
