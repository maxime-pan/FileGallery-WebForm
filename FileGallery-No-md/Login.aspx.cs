using System;
using System.Web.UI;

namespace FileGallery
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // If already logged in, redirect to admin
            if (Session["IsAdmin"] != null && (bool)Session["IsAdmin"])
            {
                Response.Redirect("Admin.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;

            if (username == "admin" && password == "Admin@123")
            {
                Session["IsAdmin"] = true;
                Session["Username"] = username;
                Response.Redirect("Admin.aspx");
            }
            else
            {
                ErrorPanel.Visible = true;
                ErrorMessage.Text = "Invalid username or password. Please try again.";
            }
        }
    }
}