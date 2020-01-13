# Use Cases

Flipt provides a solution for **feature flagging**. The next few sections provide examples of how Flipt can be used.

## A/B Testing

A/B testing can be accomplished by setting up a percentage rollout in Flipt. First you will need to create a segment. This is detailed in [Getting Started]({{< relref "/docs/getting_started" >}}). You can simply create a segment with no constraints, which will match all users.

Next you will want to create a flag with some variants by going to **Flags -> New Flag**. For this example I have created two variants: group-a and group-b.

After you have both your segment and flag created, head on over to the **Targeting** tab in the flag that you just made. Then select **New Rule**. From here you can match on your newly created segment and choose **A Percentage Rollout** from the dropdown.

Next, choose your percentages like so:

{{< figure src="/img/use_cases/flag_targeting_rollout.png" alt="Flag Targeting" >}}

Now that your A/B testing flag is all set up you can begin to make requests! Using your favoring Flipt gRPC client library, you can call the `Evaluate` method with the request parameters.

*Language: Go*
```go
res, err := client.Evaluate(context.Background(), &flipt.EvaluationRequest{
		FlagKey:  "new-landing-page",
		EntityId: "test@email.com",
	})
```

{{< hint info >}}
Notice that we are using an email address for the `EntityId`. This does not need to be an email address, it just needs to be a unique identifier for users.
{{< /hint >}}

One of the fields in the reulting struct is `Value`. You can check this to determine what landing page to respond with:

```go
if res.Value == "group-a" {
  // Render landing page for group a
} else {
  // Render landing page for group b
}
```