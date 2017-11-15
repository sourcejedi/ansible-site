This is my ansible setup.

I hope it provides some interesting examples.
I am trying to standardize on some practices
(some documentation in relevant section below).


## Checking out this git repo

This repo uses git submodules, to track the roles from Ansible Galaxy.

If you don't know what that means - a simple `git clone` will not include the roles from Ansible Galaxy.
If you want them, please read the [submodules chapter](https://alx.github.io/gitbook/5_submodules.html),
especially the pitfalls section.
I suggest also familiarizing yourself with using the reflog, to recover dangling commits.
Apologies for any frustration caused.


## Ansible practices

### Resuming after errors

In general, resuming an Ansible play which had failed will silently skip needed steps.[[1]][resuming-on-error]
Therefore failures require some thought in response.
I think I should be prepared for this to happen, even if the machines I'm managing aren't really remote.
(If they were, I would consider running ansible on a "jump host" inside `tmux` or equivalent).

When I want to run a specific role, I tend to only to run that role (using tags).
Firstly to save time, but secondly it means I know I won't have to deal with resuming an unrelated role.
However I also tend to want assurance that all roles are in sync.
In this case I run a full check first, so I can see what's going to be changed.

This means "check mode" is quite important to me.  It requires some extra effort:

> If you run check mode when etckeeper is not fully installed, the play will fail.  This behaviour is expected, as a complex role where some tasks depend on earlier ones.  We take care to produce this behaviour, making sure that check mode doesn't skip certain types of task and then give a misleading report of "changed=0".[[2]][checkmode-idiom].

[resuming-on-error] https://unix.stackexchange.com/questions/327594/ansible-resumable-plays-e-g-with-site-retry
[checkmode-idiom] https://stackoverflow.com/questions/42602154/idioms-for-using-the-command-module

This is less helpful if I'm _expecting_ to change a large number of roles at once.
For this case, I use `--list-tasks` to check what I'm doing.

I don't know that this is a comprehensive approach.
You could also argue that requiring roles to support check mode is too strict to be realistic.
However I find check mode reassuring, on machines where there may also be some manual configuration.
