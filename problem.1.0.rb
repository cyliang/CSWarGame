require 'io/console'
require 'msf/core'

class Metasploit3 < Msf::Auxiliary
	def initialize
		super(
			'Name' => 'Connect to server! easy start',
			'Version' => '$Revision:$',
			'Description' => 'Get the key immediately by this module.',
			'Author' => ['Femi'],
			'Liciense' => MSF_LICENSE,
			'Reference' => []
		)

		register_options([
			OptAddress.new('WHOST', [
				true,
				'the workstation host',
				'wargame2.cs.nctu.edu.tw'
			]),
			OptAddress.new('THOST', [
				true,
				'the target host',
				''
			]),
			OptPort.new('TPORT', [
				true,
				'the target port',
				''
			]),
			OptString.new('ACCOUNT', [
				false,
				'the website account',
				''
			]),
			OptString.new('PASSWORD', [
				false,
				'the website password',
				''
			])
		], self.class)
	end

	def run
		whost = datastore['WHOST']
		thost = datastore['THOST']
		tport = datastore['TPORT']

		account = datastore['ACCOUNT']
		password = datastore['PASSWORD']
		if account.empty?
			print "Please enter your account: "
			account = gets.chomp!
		end
		if password.empty?
			print "Please enter your password: "
			password = STDIN.noecho(&:gets).chomp!
		end

		puts "\nPlease wait for the result..."
		Net::SSH.start(whost, account, :password => password) do |ssh|
			ssh.exec!("{ echo '#{account}'; sleep 1; } | telnet #{thost} #{tport} | grep 'key: ' | cut -d ' ' -f 2") do |ch2, stream, data|
				if stream == :stdout
					puts "Your key is: \e[1;33m#{data}\e[m"
				end
			end
		end
	end
end

