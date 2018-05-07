fundle plugin 'fisherman/git_util'

function __check_git_status_prompt
	print_color cyan (basename $PWD)

	if git_is_touched
		echo -n ' has'
		print_color yellow ' ✱ uncommitted changes'
	end

	set -l ahead (git_ahead)
	if test "$ahead" = "+" -o "$ahead" = "±"
		if git_is_touched
			echo -n ' and'
		else
			echo -n ' has'
		end

		if test "$ahead" = "+"
			print_color blue ' ⇡ unpushed commits'
		else
			print_color red ' ↯ diverged from upstream'
		end
	end

	echo -n '. Continue? '
end

function __check_git_status_post --on-event postcd
	if test $check_git_status_old_pwd
		builtin cd $check_git_status_old_pwd
		set -e check_git_status_old_pwd

		echo
		echo -n 'Staying in '
		print_color cyan (basename $PWD)
		echo '.'
		echo

		sleep 1

		git status
	end
end

function __check_git_status --on-event precd
	if git_is_repo
		set -l ahead (git_ahead)

		if git_is_touched; or test "$ahead" = "+" -o "$ahead" = "±"
			read --prompt=__check_git_status_prompt confirm

			if test $confirm = 'n'
				set -g check_git_status_old_pwd $PWD
			else
				set -e check_git_status_old_pwd
			end
		end
	end
end
