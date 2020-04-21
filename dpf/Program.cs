using Mono.Unix;
using System;
using System.IO;

namespace DockerPermissionFix
{
    class Program
    {
        static UnixUserInfo restrictedUser;
        static UnixGroupInfo restrictedGroup;
        const string targetPath = "/factorio/";
        const string username = "factorio";
        const string groupname = "users";

        static void Main(string[] args)
        {
            try
            {
                restrictedUser = new UnixUserInfo(username);
                restrictedGroup = new UnixGroupInfo(groupname);
            }
            catch (ArgumentException argException)
            {
                Console.WriteLine($"Cannot create security objects for the user/group.");
                Environment.Exit(1);
            }

            Recurse(targetPath);
            Environment.Exit(0);
        }

        static void Recurse(string path)
        {
            try
            {
                var fInfo = UnixFileInfo.GetFileSystemEntry(path);
                try
                {
                    fInfo.SetOwner(restrictedUser, restrictedGroup);
                    Console.WriteLine($"Changed ownership for '{fInfo.FullName}'");
                }
                catch (Exception any)
                {
                    Console.WriteLine($"Error: {any.Message}");
                }

                if (fInfo is UnixDirectoryInfo)
                {
                    var dInfo = fInfo as UnixDirectoryInfo;
                    var content = dInfo.GetFileSystemEntries();
                    foreach (var currentEntry in content)
                    {
                        Recurse(currentEntry.FullName);
                    }
                }
            }
            catch (Exception any)
            {
                Console.WriteLine($"Error {any.GetType().Name}: {any.Message}");
            }
        }
    }
}
