#Role for tick stack master, needs base and tickmaster profile
class role::tick_master {

  #This role would be made of all the profiles that need to be included to make a database server work
  #All roles should include the base profile
  include profile::base
  include profile::tickmaster
  #include profile::dns::server
}
