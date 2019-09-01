# User Data Layouts

User-data scripts support layouts.  This is useful if you have common setup and finish code with your user-data scripts. Here's an example: `app/user_data/layouts/default.sh`:

```bash
#!/bin/bash
# do some setup
<%= yield %>
# finish work
```

And `app/user_data/box.sh`:

    yum install -y vim

The resulting generated user-data script will be:

```bash
#!/bin/bash
# do some setup
yum install -y vim
# finish work
```

You can specify the layout to use when you call the `user_data` helper method in your profile. Example: `profiles/box.yml`:

```yaml
---
...
user_data: <%= user_data("box.sh", layout: "mylayout" ) %>
...
```

If there's a `layouts/default.sh`, then it will automatically be used without having to specify the layout option.  You can disable this behavior by passing in `layout: false` or by deleting the `layouts/default.sh` file.

