/**
 * Helper to use the Command Line Interface (CLI) easily with both Windows and Unix environments.
 * Requires underscore or lodash as global through "_".
 */
export class Cli {
    /**
     * Execute a CLI command.
     * Manage Windows and Unix environment and try to execute the command on both env if fails.
     * Order: Windows -> Unix.
     *
     * @param command                   Command to execute. ('grunt')
     * @param args                      Args of the command. ('watch')
     * @param callback                  Success.
     * @param callbackErrorWindows      Failure on Windows env.
     * @param callbackErrorUnix         Failure on Unix env.
     */
    public static execute(
        command: string,
        args: string[] = [],
        callback?: any,
        callbackErrorWindows?: any,
        callbackErrorUnix?: any
    ) {
        Cli.windows(command, args, callback, function() {
            callbackErrorWindows()

            try {
                Cli.unix(command, args, callback, callbackErrorUnix)
            } catch (e) {
                console.log(
                    '------------- Failed to perform the command: "' +
                        command +
                        '" on all environments. -------------'
                )
            }
        })
    }

    /**
     * Execute a command on Windows environment.
     *
     * @param command       Command to execute. ('grunt')
     * @param args          Args of the command. ('watch')
     * @param callback      Success callback.
     * @param callbackError Failure callback.
     */
    public static windows(
        command: string,
        args: string[] = [],
        callback?: any,
        callbackError?: any
    ) {
        try {
            const params = ['/c', command, ...args].filter(
                (item, index) => params.indexOf(item) === index
            )
            Cli._execute(process.env.comspec, params)
            callback(command, args, 'Windows')
        } catch (e) {
            callbackError(command, args, 'Windows')
        }
    }

    /**
     * Execute a command on Unix environment.
     *
     * @param command       Command to execute. ('grunt')
     * @param args          Args of the command. ('watch')
     * @param callback      Success callback.
     * @param callbackError Failure callback.
     */
    public static unix(
        command: string,
        args: string[] = [],
        callback?: any,
        callbackError?: any
    ) {
        try {
            Cli._execute(command, args)
            callback(command, args, 'Unix')
        } catch (e) {
            callbackError(command, args, 'Unix')
        }
    }

    /**
     * Execute a command no matters what's the environment.
     *
     * @param command   Command to execute. ('grunt')
     * @param args      Args of the command. ('watch')
     * @private
     */
    private static _execute(command, args) {
        var spawn = require('child_process').spawn
        var childProcess = spawn(command, args)

        childProcess.stdout.on('data', function(data) {
            console.log(data.toString())
        })

        childProcess.stderr.on('data', function(data) {
            console.error(data.toString())
        })
    }
}
